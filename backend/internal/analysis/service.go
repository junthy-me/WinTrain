package analysis

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"wintrain/backend/internal/config"
	"wintrain/backend/internal/domain"
)

const (
	defaultDashScopeBaseURL = "https://dashscope.aliyuncs.com/compatible-mode/v1"
	defaultQwenModel        = "qwen3.5-plus"
	base64VideoLimitBytes   = 7 * 1024 * 1024
	publicURLLimitBytes     = 100 * 1024 * 1024
)

type RunRequest struct {
	SessionID  string
	ExerciseID string
	VideoPath  string
}

type Provider interface {
	Analyze(ctx context.Context, request ProviderRequest) (*ProviderResponse, error)
}

type ProviderRequest struct {
	ExerciseID string
	VideoPath  string
}

type ProviderResponse struct {
	Status              string
	OverallSummary      string
	MemoryCue           *string
	Feedbacks           []domain.Feedback
	LowConfidenceReason *string
}

type Service struct {
	config   config.Config
	provider Provider
}

func NewService(cfg config.Config) *Service {
	var provider Provider = &MockProvider{}
	if cfg.AnalysisMode == "vision" {
		provider = &OpenAICompatibleProvider{
			BaseURL:     cfg.OpenAIBaseURL,
			APIKey:      cfg.OpenAIAPIKey,
			Model:       cfg.OpenAIModel,
			Temperature: cfg.OpenAITemperature,
			VideoFPS:    cfg.OpenAIVideoFPS,
			Client:      &http.Client{Timeout: cfg.ProviderTimeout},
		}
	}

	return &Service{
		config:   cfg,
		provider: provider,
	}
}

func (s *Service) Run(ctx context.Context, request RunRequest) (*ProviderResponse, error) {
	runCtx, cancel := context.WithTimeout(ctx, s.config.AnalysisTimeout)
	defer cancel()

	result, err := s.provider.Analyze(runCtx, ProviderRequest{
		ExerciseID: request.ExerciseID,
		VideoPath:  request.VideoPath,
	})
	if err != nil {
		if errors.Is(runCtx.Err(), context.DeadlineExceeded) {
			return nil, domain.ErrAnalysisTimeout
		}
		var appErr *domain.AppError
		if errors.As(err, &appErr) {
			return nil, appErr
		}
		return nil, domain.ErrProviderUnavailable
	}
	return normalizeProviderResponse(result), nil
}

type MockProvider struct{}

func (p *MockProvider) Analyze(_ context.Context, request ProviderRequest) (*ProviderResponse, error) {
	switch request.ExerciseID {
	case "lat-pulldown":
		return &ProviderResponse{
			Status:         "success",
			OverallSummary: "整体动作连贯，但存在明显的后仰借力和头部前引。",
			MemoryCue:      stringPointer("下巴微收，手肘向下，核心稳住。"),
			Feedbacks: []domain.Feedback{
				{
					Rank:        1,
					Title:       "身体后仰借力",
					Description: "拉下时通过躯干后仰代替背部发力。",
					HowToFix:    "减轻重量，先稳住核心，再用手肘向下带动横杆。",
					Cue:         "核心稳住，手肘向下。",
					Severity:    "major",
					Clip:        &domain.Clip{StartMS: 2200, EndMS: 4200},
				},
			},
		}, nil
	default:
		return &ProviderResponse{
			Status:         "success",
			OverallSummary: "整体动作基本稳定，但最低点脚跟离地，影响平衡。",
			MemoryCue:      stringPointer("屁股向后坐，脚跟踩实地面。"),
			Feedbacks: []domain.Feedback{
				{
					Rank:        1,
					Title:       "脚跟离地",
					Description: "深蹲最低点脚跟抬起，说明重心过于前移。",
					HowToFix:    "下降时保持足中和脚跟受力，必要时先减少深度。",
					Cue:         "脚跟踩死地面。",
					Severity:    "major",
					Clip:        &domain.Clip{StartMS: 1800, EndMS: 3600},
				},
			},
		}, nil
	}
}

type OpenAICompatibleProvider struct {
	BaseURL     string
	APIKey      string
	Model       string
	Temperature float64
	VideoFPS    int
	Client      *http.Client
}

func (p *OpenAICompatibleProvider) Analyze(ctx context.Context, request ProviderRequest) (*ProviderResponse, error) {
	videoPart, err := buildVideoContent(request.VideoPath, p.VideoFPS)
	if err != nil {
		return nil, err
	}

	systemPrompt := promptForExercise(request.ExerciseID)
	userContent := []map[string]any{
		videoPart,
		{
			"type": "text",
			"text": "请分析这段视频，并严格遵守 system 中的要求。只返回一个 JSON 对象。",
		},
	}

	payload := map[string]any{
		"model":       defaultIfEmpty(p.Model, defaultQwenModel),
		"temperature": p.Temperature,
		"messages": []map[string]any{
			{
				"role":    "system",
				"content": systemPrompt,
			},
			{
				"role":    "user",
				"content": userContent,
			},
		},
	}

	requestBytes, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}
	baseURL := defaultIfEmpty(strings.TrimRight(p.BaseURL, "/"), defaultDashScopeBaseURL)
	httpRequest, err := http.NewRequestWithContext(ctx, http.MethodPost, baseURL+"/chat/completions", strings.NewReader(string(requestBytes)))
	if err != nil {
		return nil, err
	}
	httpRequest.Header.Set("Authorization", "Bearer "+p.APIKey)
	httpRequest.Header.Set("Content-Type", "application/json")

	httpResponse, err := p.Client.Do(httpRequest)
	if err != nil {
		return nil, err
	}
	defer httpResponse.Body.Close()

	if httpResponse.StatusCode >= http.StatusBadRequest {
		return nil, fmt.Errorf("provider status %d", httpResponse.StatusCode)
	}

	var envelope struct {
		Choices []struct {
			Message struct {
				Content any `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.NewDecoder(httpResponse.Body).Decode(&envelope); err != nil {
		return nil, err
	}
	if len(envelope.Choices) == 0 {
		return nil, errors.New("provider returned no choices")
	}

	responseText, err := extractResponseText(envelope.Choices[0].Message.Content)
	if err != nil {
		return nil, err
	}
	slog.Info("analysis_provider_raw_response",
		slog.String("exercise_id", request.ExerciseID),
		slog.String("response_text", responseText),
	)

	var parsed ProviderResponse
	jsonBytes, err := extractJSONObject(responseText)
	if err != nil {
		return nil, err
	}
	if err := json.Unmarshal(jsonBytes, &parsed); err != nil {
		return nil, err
	}
	return &parsed, nil
}

func normalizeProviderResponse(response *ProviderResponse) *ProviderResponse {
	if response == nil {
		reason := "provider returned no structured result"
		return &ProviderResponse{
			Status:              "failed",
			OverallSummary:      "本次分析未成功生成结构化结果。",
			MemoryCue:           nil,
			LowConfidenceReason: &reason,
		}
	}

	switch response.Status {
	case "success", "low_confidence", "failed":
	default:
		reason := "provider status is invalid or missing"
		response.Status = "low_confidence"
		response.LowConfidenceReason = &reason
	}

	response.OverallSummary = strings.TrimSpace(response.OverallSummary)
	if response.MemoryCue != nil {
		trimmed := strings.TrimSpace(*response.MemoryCue)
		if trimmed == "" {
			response.MemoryCue = nil
		} else {
			response.MemoryCue = &trimmed
		}
	}

	for index := range response.Feedbacks {
		response.Feedbacks[index].Severity = normalizeSeverity(response.Feedbacks[index].Severity)
		response.Feedbacks[index].Title = strings.TrimSpace(response.Feedbacks[index].Title)
		response.Feedbacks[index].Description = strings.TrimSpace(response.Feedbacks[index].Description)
		response.Feedbacks[index].HowToFix = strings.TrimSpace(response.Feedbacks[index].HowToFix)
		response.Feedbacks[index].Cue = strings.TrimSpace(response.Feedbacks[index].Cue)
	}

	if response.Status == "success" && len(response.Feedbacks) == 0 {
		reason := "provider omitted feedback items"
		response.Status = "low_confidence"
		response.LowConfidenceReason = &reason
	}
	if response.Status == "low_confidence" && response.LowConfidenceReason == nil {
		reason := "provider could not reliably analyze the movement"
		response.LowConfidenceReason = &reason
	}

	return response
}

func normalizeSeverity(raw string) string {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "major", "high":
		return "major"
	case "minor", "medium", "low":
		return "minor"
	default:
		return "info"
	}
}

func promptForExercise(exerciseID string) string {
	if exerciseID == "lat-pulldown" {
		return latPulldownPrompt
	}
	return squatPrompt
}

func buildVideoContent(videoPath string, fps int) (map[string]any, error) {
	info, err := os.Stat(videoPath)
	if err != nil {
		return nil, domain.ErrInvalidRequest
	}
	if info.Size() > publicURLLimitBytes {
		return nil, domain.NewAppError(
			http.StatusBadRequest,
			"video_not_supported_for_qwen_direct_mode",
			"Uploaded video exceeds the current direct QWen video-analysis size limit.",
			false,
		)
	}
	if info.Size() >= base64VideoLimitBytes {
		return nil, domain.NewAppError(
			http.StatusBadRequest,
			"video_requires_public_url",
			"Uploaded video is too large for the current direct QWen video-analysis path. Please shorten or recompress the clip.",
			false,
		)
	}

	content, err := os.ReadFile(videoPath)
	if err != nil {
		return nil, domain.ErrInvalidRequest
	}

	videoURL := map[string]any{
		"url": "data:" + detectVideoMIME(filepath.Ext(videoPath)) + ";base64," + base64.StdEncoding.EncodeToString(content),
	}
	if fps > 0 {
		videoURL["fps"] = fps
	}

	return map[string]any{
		"type":      "video_url",
		"video_url": videoURL,
	}, nil
}

func detectVideoMIME(extension string) string {
	switch strings.ToLower(extension) {
	case ".mp4":
		return "video/mp4"
	case ".mov":
		return "video/quicktime"
	case ".m4v":
		return "video/x-m4v"
	default:
		return "video/mp4"
	}
}

func defaultIfEmpty(value string, fallback string) string {
	if strings.TrimSpace(value) == "" {
		return fallback
	}
	return value
}

func stringPointer(value string) *string {
	return &value
}

func extractResponseText(raw any) (string, error) {
	switch value := raw.(type) {
	case string:
		return value, nil
	case []any:
		var builder strings.Builder
		for _, item := range value {
			part, ok := item.(map[string]any)
			if !ok {
				continue
			}
			if text, ok := part["text"].(string); ok {
				builder.WriteString(text)
			}
		}
		if builder.Len() > 0 {
			return builder.String(), nil
		}
	}
	return "", errors.New("unsupported provider content shape")
}

var codeFenceJSONPattern = regexp.MustCompile("(?s)```(?:json)?\\s*(\\{.*\\})\\s*```")

func extractJSONObject(rawText string) ([]byte, error) {
	trimmed := strings.TrimSpace(rawText)
	if trimmed == "" {
		return nil, errors.New("response is empty")
	}
	if strings.HasPrefix(trimmed, "{") && json.Valid([]byte(trimmed)) {
		return []byte(trimmed), nil
	}
	if matches := codeFenceJSONPattern.FindStringSubmatch(trimmed); len(matches) == 2 {
		candidate := strings.TrimSpace(matches[1])
		if json.Valid([]byte(candidate)) {
			return []byte(candidate), nil
		}
	}
	return nil, errors.New("no valid JSON object found")
}
