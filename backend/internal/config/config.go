package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	Address              string
	MaxUploadBytes       int64
	AnalysisTimeout      time.Duration
	ProviderTimeout      time.Duration
	QuotaSnapshotTTL     time.Duration
	KeyframeCount        int
	KeyframeLongEdge     int
	TempDir              string
	AnalysisMode         string
	OpenAIBaseURL        string
	OpenAIAPIKey         string
	OpenAIModel          string
	OpenAITemperature    float64
	OpenAIVideoFPS       int
	AppStoreSharedSecret string
}

func Load() Config {
	openAIAPIKey := firstEnv("WINTRAIN_OPENAI_API_KEY", "DASHSCOPE_API_KEY", "OPENAI_API_KEY")
	openAIBaseURL := envOrDefault("WINTRAIN_OPENAI_BASE_URL", envOrDefault("DASHSCOPE_BASE_URL", ""))
	if openAIBaseURL == "" && openAIAPIKey != "" {
		openAIBaseURL = "https://dashscope.aliyuncs.com/compatible-mode/v1"
	}

	analysisMode := strings.ToLower(strings.TrimSpace(envOrDefault("WINTRAIN_ANALYSIS_MODE", "")))
	if analysisMode == "" {
		if openAIAPIKey != "" {
			analysisMode = "vision"
		} else {
			analysisMode = "mock"
		}
	}

	return Config{
		Address:              envOrDefault("WINTRAIN_HTTP_ADDR", ":8080"),
		MaxUploadBytes:       envOrDefaultInt64("WINTRAIN_MAX_UPLOAD_BYTES", 200*1024*1024),
		AnalysisTimeout:      envOrDefaultDuration("WINTRAIN_ANALYSIS_TIMEOUT", 75*time.Second),
		ProviderTimeout:      envOrDefaultDuration("WINTRAIN_PROVIDER_TIMEOUT", 45*time.Second),
		QuotaSnapshotTTL:     envOrDefaultDuration("WINTRAIN_QUOTA_TTL", 5*time.Minute),
		KeyframeCount:        envOrDefaultInt("WINTRAIN_KEYFRAME_COUNT", 10),
		KeyframeLongEdge:     envOrDefaultInt("WINTRAIN_KEYFRAME_LONG_EDGE", 1280),
		TempDir:              envOrDefault("WINTRAIN_TEMP_DIR", os.TempDir()),
		AnalysisMode:         analysisMode,
		OpenAIBaseURL:        openAIBaseURL,
		OpenAIAPIKey:         openAIAPIKey,
		OpenAIModel:          envOrDefault("WINTRAIN_OPENAI_MODEL", envOrDefault("LLM_SPIKE_MODEL", "qwen3.5-plus")),
		OpenAITemperature:    envOrDefaultFloat("WINTRAIN_OPENAI_TEMPERATURE", 0),
		OpenAIVideoFPS:       envOrDefaultInt("WINTRAIN_OPENAI_VIDEO_FPS", 2),
		AppStoreSharedSecret: envOrDefault("WINTRAIN_APP_STORE_SHARED_SECRET", ""),
	}
}

func (c Config) Validate() error {
	switch c.AnalysisMode {
	case "mock":
		return nil
	case "vision":
		var missing []string
		if c.OpenAIBaseURL == "" {
			missing = append(missing, "WINTRAIN_OPENAI_BASE_URL")
		}
		if c.OpenAIAPIKey == "" {
			missing = append(missing, "WINTRAIN_OPENAI_API_KEY or OPENAI_API_KEY")
		}
		if c.OpenAIModel == "" {
			missing = append(missing, "WINTRAIN_OPENAI_MODEL")
		}
		if len(missing) > 0 {
			return fmt.Errorf("analysis mode vision requires: %s", strings.Join(missing, ", "))
		}
		return nil
	default:
		return fmt.Errorf("unsupported WINTRAIN_ANALYSIS_MODE: %s", c.AnalysisMode)
	}
}

func (c Config) AnalysisProviderLabel() string {
	if c.AnalysisMode == "vision" {
		if strings.Contains(strings.ToLower(c.OpenAIBaseURL), "dashscope") || strings.Contains(strings.ToLower(c.OpenAIModel), "qwen") {
			return "qwen-dashscope"
		}
		return "openai-compatible"
	}
	return "mock"
}

func envOrDefault(key string, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

func firstEnv(keys ...string) string {
	for _, key := range keys {
		if value := os.Getenv(key); value != "" {
			return value
		}
	}
	return ""
}

func envOrDefaultInt(key string, fallback int) int {
	if value := os.Getenv(key); value != "" {
		if parsed, err := strconv.Atoi(value); err == nil {
			return parsed
		}
	}
	return fallback
}

func envOrDefaultInt64(key string, fallback int64) int64 {
	if value := os.Getenv(key); value != "" {
		if parsed, err := strconv.ParseInt(value, 10, 64); err == nil {
			return parsed
		}
	}
	return fallback
}

func envOrDefaultFloat(key string, fallback float64) float64 {
	if value := os.Getenv(key); value != "" {
		if parsed, err := strconv.ParseFloat(value, 64); err == nil {
			return parsed
		}
	}
	return fallback
}

func envOrDefaultDuration(key string, fallback time.Duration) time.Duration {
	if value := os.Getenv(key); value != "" {
		if parsed, err := time.ParseDuration(value); err == nil {
			return parsed
		}
	}
	return fallback
}
