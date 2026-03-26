package spike

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const (
	DefaultDashScopeBaseURL = "https://dashscope.aliyuncs.com/compatible-mode/v1"
	DefaultModel            = "qwen3.5-plus"
	DefaultInputRateCNY     = 0.8
	DefaultOutputRateCNY    = 4.8
	Base64VideoLimitBytes   = 7 * 1024 * 1024
	PublicURLLimitBytes     = 100 * 1024 * 1024
)

type RunConfig struct {
	SampleID      string
	RunID         string
	VideoPath     string
	VideoURL      string
	PromptPath    string
	OutputRoot    string
	BaseURL       string
	Model         string
	APIKey        string
	FPS           int
	Timeout       time.Duration
	InputRateCNY  float64
	OutputRateCNY float64
}

type RunResult struct {
	ResponseFile string
	MetricsFile  string
	LatencyMS    int64
	RequestMode  string
}

func BuildRequest(config RunConfig) (ChatCompletionsRequest, string, int64, error) {
	if strings.TrimSpace(config.VideoPath) == "" {
		return ChatCompletionsRequest{}, "", 0, errors.New("video path is required")
	}
	if strings.TrimSpace(config.PromptPath) == "" {
		return ChatCompletionsRequest{}, "", 0, errors.New("prompt path is required")
	}
	model := config.Model
	if model == "" {
		model = DefaultModel
	}

	promptBytes, err := os.ReadFile(config.PromptPath)
	if err != nil {
		return ChatCompletionsRequest{}, "", 0, fmt.Errorf("read prompt: %w", err)
	}

	videoPart, requestMode, videoSize, err := buildVideoContent(config.VideoPath, config.VideoURL, config.FPS)
	if err != nil {
		return ChatCompletionsRequest{}, "", 0, err
	}

	request := ChatCompletionsRequest{
		Model:       model,
		Temperature: 0,
		Messages: []Message{
			{
				Role: "user",
				Content: []ContentPart{
					videoPart,
					{
						Type: "text",
						Text: string(promptBytes),
					},
				},
			},
		},
	}
	return request, requestMode, videoSize, nil
}

func RunAnalysis(ctx context.Context, config RunConfig) (*RunResult, error) {
	if strings.TrimSpace(config.APIKey) == "" {
		return nil, errors.New("DASHSCOPE_API_KEY is required")
	}
	if strings.TrimSpace(config.SampleID) == "" {
		return nil, errors.New("sample id is required")
	}
	if strings.TrimSpace(config.RunID) == "" {
		return nil, errors.New("run id is required")
	}

	request, requestMode, videoSize, err := BuildRequest(config)
	if err != nil {
		return nil, err
	}

	baseURL := strings.TrimRight(config.BaseURL, "/")
	if baseURL == "" {
		baseURL = DefaultDashScopeBaseURL
	}

	requestBytes, err := json.Marshal(request)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	startedAt := time.Now().UTC()
	httpRequest, err := http.NewRequestWithContext(ctx, http.MethodPost, baseURL+"/chat/completions", bytes.NewReader(requestBytes))
	if err != nil {
		return nil, fmt.Errorf("build request: %w", err)
	}
	httpRequest.Header.Set("Authorization", "Bearer "+config.APIKey)
	httpRequest.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: config.Timeout}
	start := time.Now()
	httpResponse, requestErr := client.Do(httpRequest)
	latency := time.Since(start).Milliseconds()
	completedAt := time.Now().UTC()

	var responseBody []byte
	statusCode := 0
	if httpResponse != nil {
		statusCode = httpResponse.StatusCode
		responseBody, err = io.ReadAll(httpResponse.Body)
		httpResponse.Body.Close()
		if err != nil {
			return nil, fmt.Errorf("read response: %w", err)
		}
	}

	record := RecordedRun{
		SampleID:    config.SampleID,
		RunID:       config.RunID,
		VideoPath:   config.VideoPath,
		VideoURL:    config.VideoURL,
		RequestMode: requestMode,
		Model:       request.Model,
		PromptPath:  config.PromptPath,
		Request:     request,
		HTTPStatus:  statusCode,
		StartedAt:   startedAt.Format(time.RFC3339Nano),
		CompletedAt: completedAt.Format(time.RFC3339Nano),
	}

	if len(responseBody) > 0 {
		record.RawResponse = responseBody
		if responseText, textErr := ExtractResponseText(responseBody); textErr == nil {
			record.ResponseText = responseText
		}
	}
	if requestErr != nil {
		record.Error = requestErr.Error()
	}
	if statusCode >= http.StatusBadRequest {
		record.Error = fmt.Sprintf("dashscope returned status %d", statusCode)
	}

	responseFile := filepath.Join(config.OutputRoot, config.SampleID, config.RunID+".json")
	if err := writeJSON(responseFile, record); err != nil {
		return nil, err
	}

	metric := CallMetric{
		SampleID:     config.SampleID,
		RunID:        config.RunID,
		ResponseFile: responseFile,
		Model:        request.Model,
		RequestMode:  requestMode,
		VideoPath:    config.VideoPath,
		VideoBytes:   videoSize,
		LatencyMS:    latency,
		HTTPStatus:   statusCode,
		StartedAt:    record.StartedAt,
		CompletedAt:  record.CompletedAt,
		Error:        record.Error,
	}

	if len(responseBody) > 0 {
		var envelope ChatCompletionsResponse
		if err := json.Unmarshal(responseBody, &envelope); err == nil {
			metric.InputTokens = pointerIfPositive(envelope.Usage.PromptTokens)
			metric.OutputTokens = pointerIfPositive(envelope.Usage.CompletionTokens)
			metric.TotalTokens = pointerIfPositive(envelope.Usage.TotalTokens)
			metric.EstimatedCostCNY = estimateCostCNY(envelope.Usage.PromptTokens, envelope.Usage.CompletionTokens, config.InputRateCNY, config.OutputRateCNY)
		}
	}

	metricsFile := filepath.Join(config.OutputRoot, "call_metrics.json")
	if err := appendMetric(metricsFile, metric); err != nil {
		return nil, err
	}

	if requestErr != nil {
		return nil, fmt.Errorf("request failed after writing artifacts: %w", requestErr)
	}
	if statusCode >= http.StatusBadRequest {
		return nil, fmt.Errorf("dashscope returned status %d; response saved to %s", statusCode, responseFile)
	}

	return &RunResult{
		ResponseFile: responseFile,
		MetricsFile:  metricsFile,
		LatencyMS:    latency,
		RequestMode:  requestMode,
	}, nil
}

func buildVideoContent(videoPath string, videoURL string, fps int) (ContentPart, string, int64, error) {
	info, err := os.Stat(videoPath)
	if err != nil {
		return ContentPart{}, "", 0, fmt.Errorf("stat video: %w", err)
	}
	if info.Size() > PublicURLLimitBytes {
		return ContentPart{}, "", info.Size(), fmt.Errorf("video is %d bytes; official spike path supports up to %d bytes", info.Size(), PublicURLLimitBytes)
	}

	part := ContentPart{
		Type: "video_url",
		VideoURL: &VideoURLPart{
			FPS: fps,
		},
	}

	if strings.TrimSpace(videoURL) != "" {
		part.VideoURL.URL = videoURL
		return part, "public_url", info.Size(), nil
	}

	if info.Size() >= Base64VideoLimitBytes {
		return ContentPart{}, "", info.Size(), fmt.Errorf("video is %d bytes; OpenAI-compatible mode requires a public URL for files >= %d bytes", info.Size(), Base64VideoLimitBytes)
	}

	content, err := os.ReadFile(videoPath)
	if err != nil {
		return ContentPart{}, "", info.Size(), fmt.Errorf("read video: %w", err)
	}
	mimeType := detectVideoMIME(filepath.Ext(videoPath))
	part.VideoURL.URL = "data:" + mimeType + ";base64," + base64.StdEncoding.EncodeToString(content)
	return part, "data_url", info.Size(), nil
}

func detectVideoMIME(extension string) string {
	switch strings.ToLower(extension) {
	case ".mp4":
		return "video/mp4"
	case ".mov":
		return "video/quicktime"
	case ".m4v":
		return "video/x-m4v"
	case ".webm":
		return "video/webm"
	default:
		return "application/octet-stream"
	}
}

func estimateCostCNY(inputTokens int, outputTokens int, inputRate float64, outputRate float64) *float64 {
	if inputTokens <= 0 && outputTokens <= 0 {
		return nil
	}
	total := (float64(inputTokens) * inputRate / 1_000_000) + (float64(outputTokens) * outputRate / 1_000_000)
	return &total
}

func pointerIfPositive(value int) *int {
	if value <= 0 {
		return nil
	}
	return &value
}

func appendMetric(path string, metric CallMetric) error {
	metrics := []CallMetric{}
	if content, err := os.ReadFile(path); err == nil && len(bytes.TrimSpace(content)) > 0 {
		if err := json.Unmarshal(content, &metrics); err != nil {
			return fmt.Errorf("parse existing metrics: %w", err)
		}
	}
	metrics = append(metrics, metric)
	return writeJSON(path, metrics)
}

func writeJSON(path string, payload any) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return fmt.Errorf("mkdir %s: %w", filepath.Dir(path), err)
	}
	data, err := json.MarshalIndent(payload, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal json for %s: %w", path, err)
	}
	data = append(data, '\n')
	if err := os.WriteFile(path, data, 0o644); err != nil {
		return fmt.Errorf("write %s: %w", path, err)
	}
	return nil
}
