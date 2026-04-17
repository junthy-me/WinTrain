package httpapi

import (
	"bytes"
	"io"
	"log/slog"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"wintrain/backend/internal/analysis"
	"wintrain/backend/internal/config"
	"wintrain/backend/internal/entitlement"
	"wintrain/backend/internal/quota"
	"wintrain/backend/internal/subscription"
)

func testServer(t *testing.T) http.Handler {
	t.Helper()

	cfg := config.Config{
		MaxUploadBytes:   200 * 1024 * 1024,
		AnalysisTimeout:  30 * time.Second,
		ProviderTimeout:  15 * time.Second,
		QuotaSnapshotTTL: 5 * time.Minute,
		KeyframeCount:    10,
		KeyframeLongEdge: 1280,
		TempDir:          os.TempDir(),
		AnalysisMode:     "mock",
	}

	quotaService := quota.NewService(cfg.QuotaSnapshotTTL)
	subscriptionService := subscription.NewService(nil)
	entitlementService := entitlement.NewService(quotaService, subscriptionService)
	analysisService := analysis.NewService(cfg)
	server := NewServer(slog.Default(), cfg, entitlementService, analysisService, subscriptionService)
	return server.Routes()
}

func TestHealthEndpoint(t *testing.T) {
	server := testServer(t)
	request := httptest.NewRequest(http.MethodGet, "/health", nil)
	response := httptest.NewRecorder()

	server.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", response.Code)
	}
}

func TestQuotaEndpointRequiresInstallID(t *testing.T) {
	server := testServer(t)
	request := httptest.NewRequest(http.MethodGet, "/v1/quota", nil)
	response := httptest.NewRecorder()

	server.ServeHTTP(response, request)

	if response.Code != http.StatusBadRequest {
		t.Fatalf("expected 400, got %d", response.Code)
	}
}

func TestAnalysisEndpointConsumesQuotaOnSuccess(t *testing.T) {
	server := testServer(t)
	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	if err := writer.WriteField("exercise_id", "squat"); err != nil {
		t.Fatal(err)
	}

	part, err := writer.CreateFormFile("video", "s1.mp4")
	if err != nil {
		t.Fatal(err)
	}

	file, err := os.Open(filepath.Join("..", "..", "poc", "llm-spike", "testdata", "s1.mp4"))
	if err != nil {
		t.Fatal(err)
	}
	defer file.Close()

	if _, err := io.Copy(part, file); err != nil {
		t.Fatal(err)
	}

	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}

	request := httptest.NewRequest(http.MethodPost, "/v1/analysis", body)
	request.Header.Set("Content-Type", writer.FormDataContentType())
	request.Header.Set("X-Install-ID", "device-a")
	response := httptest.NewRecorder()

	server.ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d: %s", response.Code, response.Body.String())
	}
}

func TestSupportedExerciseID(t *testing.T) {
	tests := []struct {
		exerciseID string
		want       bool
	}{
		{exerciseID: "squat", want: true},
		{exerciseID: "lat-pulldown", want: true},
		{exerciseID: "bench-press", want: true},
		{exerciseID: "barbell-row", want: true},
		{exerciseID: "deadlift", want: true},
		{exerciseID: "unknown", want: false},
	}

	for _, tc := range tests {
		t.Run(tc.exerciseID, func(t *testing.T) {
			got := supportedExerciseID(tc.exerciseID)
			if got != tc.want {
				t.Fatalf("supportedExerciseID(%q) = %v, want %v", tc.exerciseID, got, tc.want)
			}
		})
	}
}
