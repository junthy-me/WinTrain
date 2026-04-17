package analysis

import (
	"encoding/json"
	"strings"
	"testing"

	"wintrain/backend/internal/domain"
)

// ---- normalizeProviderResponse ----

func TestNormalizeProviderResponse_NilInput(t *testing.T) {
	result := normalizeProviderResponse(nil)
	if result.Status != "failed" {
		t.Errorf("expected status=failed, got %q", result.Status)
	}
	if result.LowConfidenceReason != nil {
		t.Error("expected LowConfidenceReason to be nil for failed nil input")
	}
}

func TestNormalizeProviderResponse_SuccessWithFeedbacks(t *testing.T) {
	input := &ProviderResponse{
		Status:         "success",
		OverallSummary: "  好的动作  ",
		MemoryCue:      stringPointer("  核心稳住  "),
		Feedbacks: []domain.Feedback{
			{Rank: 1, Title: "  脚跟离地  ", Severity: "MAJOR"},
		},
	}
	result := normalizeProviderResponse(input)

	if result.Status != "success" {
		t.Errorf("expected success, got %q", result.Status)
	}
	if result.OverallSummary != "好的动作" {
		t.Errorf("expected trimmed summary, got %q", result.OverallSummary)
	}
	if result.MemoryCue == nil || *result.MemoryCue != "核心稳住" {
		t.Errorf("expected trimmed memory cue, got %v", result.MemoryCue)
	}
	if result.Feedbacks[0].Title != "脚跟离地" {
		t.Errorf("expected trimmed title, got %q", result.Feedbacks[0].Title)
	}
	if result.Feedbacks[0].Severity != "major" {
		t.Errorf("expected normalized severity=major, got %q", result.Feedbacks[0].Severity)
	}
}

func TestNormalizeProviderResponse_SuccessWithNoFeedbacks_RemainsSuccess(t *testing.T) {
	input := &ProviderResponse{
		Status:         "success",
		OverallSummary: "分析完成",
		Feedbacks:      []domain.Feedback{},
	}
	result := normalizeProviderResponse(input)

	if result.Status != "success" {
		t.Errorf("expected success for success+no-feedbacks, got %q", result.Status)
	}
	if result.LowConfidenceReason != nil {
		t.Error("expected LowConfidenceReason to be nil")
	}
}

func TestNormalizeProviderResponse_UnknownStatusWithReasonBecomesLowConfidence(t *testing.T) {
	input := &ProviderResponse{
		Status:              "unknown_status",
		OverallSummary:      "...",
		LowConfidenceReason: stringPointer("角度不足"),
		Feedbacks:           []domain.Feedback{{Rank: 1, Title: "test", Severity: "minor"}},
	}
	result := normalizeProviderResponse(input)

	if result.Status != "low_confidence" {
		t.Errorf("expected low_confidence for unknown status, got %q", result.Status)
	}
}

func TestNormalizeProviderResponse_UnknownStatusWithSummaryAndFeedbacksBecomesSuccess(t *testing.T) {
	input := &ProviderResponse{
		Status:         "unknown_status",
		OverallSummary: "整体良好",
		Feedbacks:      []domain.Feedback{},
	}
	result := normalizeProviderResponse(input)

	if result.Status != "success" {
		t.Errorf("expected success for unknown status with complete body, got %q", result.Status)
	}
}

func TestNormalizeProviderResponse_UnknownStatusWithoutSignalsBecomesFailed(t *testing.T) {
	input := &ProviderResponse{
		Status:    "unknown_status",
		Feedbacks: []domain.Feedback{},
	}
	result := normalizeProviderResponse(input)

	if result.Status != "failed" {
		t.Errorf("expected failed for unknown status without usable signals, got %q", result.Status)
	}
	if result.OverallSummary == "" {
		t.Error("expected failed summary to be injected")
	}
}

func TestNormalizeProviderResponse_LowConfidenceWithoutReasonGetsDefault(t *testing.T) {
	input := &ProviderResponse{
		Status:         "low_confidence",
		OverallSummary: "...",
	}
	result := normalizeProviderResponse(input)

	if result.LowConfidenceReason == nil {
		t.Error("expected default LowConfidenceReason to be injected")
	}
}

func TestNormalizeProviderResponse_SuccessClearsLowConfidenceReason(t *testing.T) {
	input := &ProviderResponse{
		Status:              "success",
		OverallSummary:      "ok",
		LowConfidenceReason: stringPointer("  should be cleared  "),
		Feedbacks:           []domain.Feedback{{Rank: 1, Title: "test", Severity: "minor"}},
	}
	result := normalizeProviderResponse(input)

	if result.LowConfidenceReason != nil {
		t.Errorf("expected LowConfidenceReason to be nil for success, got %v", result.LowConfidenceReason)
	}
}

func TestNormalizeProviderResponse_FailedClearsFeedbacksAndKeepsSliceNonNil(t *testing.T) {
	input := &ProviderResponse{
		Status:         "failed",
		OverallSummary: "bad input",
		Feedbacks: []domain.Feedback{
			{Rank: 1, Title: "should be removed", Severity: "major"},
		},
	}
	result := normalizeProviderResponse(input)

	if len(result.Feedbacks) != 0 {
		t.Fatalf("expected failed response to have no feedbacks, got %d", len(result.Feedbacks))
	}
	if result.Feedbacks == nil {
		t.Fatal("expected feedbacks slice to be non-nil")
	}
	if result.LowConfidenceReason != nil {
		t.Errorf("expected LowConfidenceReason to be nil for failed, got %v", result.LowConfidenceReason)
	}
}

func TestNormalizeProviderResponse_EmptyMemoryCueBecomesNil(t *testing.T) {
	input := &ProviderResponse{
		Status:         "success",
		OverallSummary: "ok",
		MemoryCue:      stringPointer("   "), // whitespace-only
		Feedbacks:      []domain.Feedback{{Rank: 1, Title: "test", Severity: "minor"}},
	}
	result := normalizeProviderResponse(input)

	if result.MemoryCue != nil {
		t.Errorf("expected whitespace-only MemoryCue to become nil, got %q", *result.MemoryCue)
	}
}

// ---- normalizeSeverity ----

func TestNormalizeSeverity(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"major", "major"},
		{"MAJOR", "major"},
		{"high", "major"},
		{"HIGH", "major"},
		{"minor", "minor"},
		{"medium", "minor"},
		{"low", "minor"},
		{"LOW", "minor"},
		{"info", "info"},
		{"", "info"},
		{"unknown", "info"},
		{"  major  ", "major"},
	}
	for _, tc := range tests {
		got := normalizeSeverity(tc.input)
		if got != tc.expected {
			t.Errorf("normalizeSeverity(%q) = %q, want %q", tc.input, got, tc.expected)
		}
	}
}

func TestPromptForExercise_SupportedExerciseIDs(t *testing.T) {
	tests := []struct {
		exerciseID string
		wantText   string
	}{
		{exerciseID: "squat", wantText: "深蹲模式"},
		{exerciseID: "lat-pulldown", wantText: "高位下拉"},
		{exerciseID: "bench-press", wantText: "杠铃卧推"},
		{exerciseID: "barbell-row", wantText: "杠铃划船"},
		{exerciseID: "deadlift", wantText: "杠铃硬拉"},
	}

	for _, tc := range tests {
		t.Run(tc.exerciseID, func(t *testing.T) {
			prompt := promptForExercise(tc.exerciseID)
			if prompt == "" {
				t.Fatal("expected non-empty prompt")
			}
			if !strings.Contains(prompt, tc.wantText) {
				t.Fatalf("expected prompt to contain %q", tc.wantText)
			}
		})
	}
}

// ---- extractJSONObject ----

func TestExtractJSONObject(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		wantErr bool
		wantKey string
	}{
		{
			name:    "bare JSON object",
			input:   `{"status":"success","overall_summary":"ok"}`,
			wantKey: "status",
		},
		{
			name:    "JSON inside markdown code fence",
			input:   "```json\n{\"status\":\"success\"}\n```",
			wantKey: "status",
		},
		{
			name:    "JSON inside plain code fence",
			input:   "```\n{\"status\":\"success\"}\n```",
			wantKey: "status",
		},
		{
			name:    "JSON with preamble text and code fence",
			input:   "Here is the result:\n```json\n{\"status\":\"low_confidence\"}\n```",
			wantKey: "status",
		},
		{
			name:    "empty string returns error",
			input:   "",
			wantErr: true,
		},
		{
			name:    "plain prose with no JSON returns error",
			input:   "I cannot analyze this video.",
			wantErr: true,
		},
		{
			name:    "invalid JSON inside code fence returns error",
			input:   "```json\n{status: broken}\n```",
			wantErr: true,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, err := extractJSONObject(tc.input)
			if tc.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil (result=%q)", got)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			var parsed map[string]any
			if err := json.Unmarshal(got, &parsed); err != nil {
				t.Fatalf("result is not valid JSON: %v", err)
			}
			if tc.wantKey != "" {
				if _, ok := parsed[tc.wantKey]; !ok {
					t.Errorf("expected key %q in parsed result", tc.wantKey)
				}
			}
		})
	}
}
