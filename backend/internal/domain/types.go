package domain

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

type QuotaSnapshot struct {
	Plan                    string `json:"plan"`
	RemainingTotalSuccesses *int   `json:"remaining_total_successes"`
	DailyRemainingSuccesses *int   `json:"daily_remaining_successes"`
	IsPro                   bool   `json:"is_pro"`
	SnapshotAt              string `json:"snapshot_at"`
	ExpiresAt               string `json:"expires_at"`
}

type AnalysisResponse struct {
	SessionID           string        `json:"session_id"`
	VideoSource         string        `json:"video_source"`
	Status              string        `json:"status"`
	ExerciseID          string        `json:"exercise_id"`
	OverallSummary      string        `json:"overall_summary"`
	MemoryCue           *string       `json:"memory_cue,omitempty"`
	Feedbacks           []Feedback    `json:"feedbacks"`
	LowConfidenceReason *string       `json:"low_confidence_reason"`
	Quota               QuotaSnapshot `json:"quota"`
}

type SubscriptionInfo struct {
	Status    string  `json:"status"`
	ProductID string  `json:"product_id"`
	ExpiresAt *string `json:"expires_at"`
}

type SubscriptionResponse struct {
	Subscription SubscriptionInfo `json:"subscription"`
	Quota        QuotaSnapshot    `json:"quota"`
}
