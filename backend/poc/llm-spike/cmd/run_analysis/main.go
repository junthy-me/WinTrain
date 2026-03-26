package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"time"

	"wintrain/backend/poc/llm-spike/internal/spike"
)

func main() {
	var (
		sampleID   = flag.String("sample", "", "sample id such as s1, s2, or s3")
		runID      = flag.String("run-id", time.Now().UTC().Format("20060102T150405Z"), "unique run id")
		videoPath  = flag.String("video", "", "path to the local video file")
		videoURL   = flag.String("video-url", "", "optional public video URL for files >= 7MB")
		promptPath = flag.String("prompt", "poc/llm-spike/prompts/analysis_v1.txt", "path to the analysis prompt")
		outputRoot = flag.String("out", "poc/llm-spike/testdata/llm_responses", "output directory for raw responses")
		baseURL    = flag.String("base-url", envOrDefault("DASHSCOPE_BASE_URL", spike.DefaultDashScopeBaseURL), "DashScope compatible-mode base URL")
		model      = flag.String("model", envOrDefault("LLM_SPIKE_MODEL", spike.DefaultModel), "model alias or pinned model name")
		fps        = flag.Int("fps", 2, "fps hint for the video input")
		timeout    = flag.Duration("timeout", 2*time.Minute, "HTTP timeout")
		dryRun     = flag.Bool("dry-run", false, "print the request payload without calling the API")
	)
	flag.Parse()

	inputRate := envOrDefaultFloat("LLM_SPIKE_INPUT_RATE_CNY_PER_MTOKENS", spike.DefaultInputRateCNY)
	outputRate := envOrDefaultFloat("LLM_SPIKE_OUTPUT_RATE_CNY_PER_MTOKENS", spike.DefaultOutputRateCNY)

	config := spike.RunConfig{
		SampleID:      *sampleID,
		RunID:         *runID,
		VideoPath:     *videoPath,
		VideoURL:      *videoURL,
		PromptPath:    *promptPath,
		OutputRoot:    *outputRoot,
		BaseURL:       *baseURL,
		Model:         *model,
		APIKey:        os.Getenv("DASHSCOPE_API_KEY"),
		FPS:           *fps,
		Timeout:       *timeout,
		InputRateCNY:  inputRate,
		OutputRateCNY: outputRate,
	}

	if *dryRun {
		request, requestMode, videoSize, err := spike.BuildRequest(config)
		if err != nil {
			exitErr(err)
		}
		data, err := json.MarshalIndent(request, "", "  ")
		if err != nil {
			exitErr(err)
		}
		fmt.Printf("request_mode=%s\nvideo_bytes=%d\n%s\n", requestMode, videoSize, string(data))
		return
	}

	result, err := spike.RunAnalysis(context.Background(), config)
	if err != nil {
		exitErr(err)
	}

	fmt.Printf("saved response=%s\nsaved metrics=%s\nlatency_ms=%d\nrequest_mode=%s\n", result.ResponseFile, result.MetricsFile, result.LatencyMS, result.RequestMode)
}

func envOrDefault(key string, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func envOrDefaultFloat(key string, fallback float64) float64 {
	if value := os.Getenv(key); value != "" {
		var parsed float64
		if _, err := fmt.Sscanf(value, "%f", &parsed); err == nil {
			return parsed
		}
	}
	return fallback
}

func exitErr(err error) {
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}
