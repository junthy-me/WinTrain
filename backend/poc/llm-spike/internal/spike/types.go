package spike

import "encoding/json"

type Clip struct {
	StartMS int `json:"start_ms"`
	EndMS   int `json:"end_ms"`
}

type Feedback struct {
	Rank        int    `json:"rank"`
	Title       string `json:"title"`
	Description string `json:"description"`
	HowToFix    string `json:"how_to_fix"`
	Cue         string `json:"cue"`
	Severity    string `json:"severity"`
	Clip        *Clip  `json:"clip,omitempty"`
}

type AnalysisOutput struct {
	Status              string     `json:"status"`
	OverallSummary      string     `json:"overall_summary"`
	MemoryCue           string     `json:"memory_cue"`
	LowConfidenceReason string     `json:"low_confidence_reason"`
	Feedbacks           []Feedback `json:"feedbacks"`
}

type ChatCompletionsRequest struct {
	Model       string    `json:"model"`
	Messages    []Message `json:"messages"`
	Temperature float64   `json:"temperature,omitempty"`
}

type Message struct {
	Role    string        `json:"role"`
	Content []ContentPart `json:"content"`
}

type ContentPart struct {
	Type     string        `json:"type"`
	Text     string        `json:"text,omitempty"`
	VideoURL *VideoURLPart `json:"video_url,omitempty"`
}

type VideoURLPart struct {
	URL string `json:"url"`
	FPS int    `json:"fps,omitempty"`
}

type Usage struct {
	PromptTokens     int `json:"prompt_tokens"`
	CompletionTokens int `json:"completion_tokens"`
	TotalTokens      int `json:"total_tokens"`
}

type ChatCompletionsResponse struct {
	ID      string `json:"id"`
	Model   string `json:"model"`
	Choices []struct {
		Message struct {
			Content json.RawMessage `json:"content"`
		} `json:"message"`
	} `json:"choices"`
	Usage Usage `json:"usage"`
}

type RecordedRun struct {
	SampleID     string                 `json:"sample_id"`
	RunID        string                 `json:"run_id"`
	VideoPath    string                 `json:"video_path"`
	VideoURL     string                 `json:"video_url,omitempty"`
	RequestMode  string                 `json:"request_mode"`
	Model        string                 `json:"model"`
	PromptPath   string                 `json:"prompt_path"`
	Request      ChatCompletionsRequest `json:"request"`
	ResponseText string                 `json:"response_text,omitempty"`
	RawResponse  json.RawMessage        `json:"raw_response,omitempty"`
	HTTPStatus   int                    `json:"http_status,omitempty"`
	StartedAt    string                 `json:"started_at"`
	CompletedAt  string                 `json:"completed_at"`
	Error        string                 `json:"error,omitempty"`
}

type CallMetric struct {
	SampleID         string   `json:"sample_id"`
	RunID            string   `json:"run_id"`
	ResponseFile     string   `json:"response_file"`
	Model            string   `json:"model"`
	RequestMode      string   `json:"request_mode"`
	VideoPath        string   `json:"video_path"`
	VideoBytes       int64    `json:"video_bytes"`
	LatencyMS        int64    `json:"latency_ms"`
	InputTokens      *int     `json:"input_tokens,omitempty"`
	OutputTokens     *int     `json:"output_tokens,omitempty"`
	TotalTokens      *int     `json:"total_tokens,omitempty"`
	EstimatedCostCNY *float64 `json:"estimated_cost_cny,omitempty"`
	HTTPStatus       int      `json:"http_status"`
	StartedAt        string   `json:"started_at"`
	CompletedAt      string   `json:"completed_at"`
	Error            string   `json:"error,omitempty"`
}

type SampleAnnotation struct {
	SampleID           string `json:"sample_id"`
	VideoFile          string `json:"video_file,omitempty"`
	Notes              string `json:"notes,omitempty"`
	TargetFeedbackRank int    `json:"target_feedback_rank,omitempty"`
	ReferenceClip      Clip   `json:"clip"`
}

type AnnotationDocument struct {
	Samples []SampleAnnotation `json:"samples"`
}
