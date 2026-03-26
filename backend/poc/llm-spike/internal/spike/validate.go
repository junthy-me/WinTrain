package spike

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"math"
	"os"
	"path/filepath"
	"slices"
	"strings"
)

type ValidateConfig struct {
	ResponseRoot    string
	AnnotationsPath string
	ResultsRoot     string
}

type ParsedRun struct {
	Path             string          `json:"path"`
	SampleID         string          `json:"sample_id"`
	RunID            string          `json:"run_id"`
	ParseError       string          `json:"parse_error,omitempty"`
	ValidationErrors []string        `json:"validation_errors,omitempty"`
	Output           *AnalysisOutput `json:"output,omitempty"`
}

type SchemaComplianceResult struct {
	TotalRuns      int         `json:"total_runs"`
	ParseableRuns  int         `json:"parseable_runs"`
	CompliantRuns  int         `json:"compliant_runs"`
	ComplianceRate float64     `json:"compliance_rate"`
	Threshold      float64     `json:"threshold"`
	Passed         bool        `json:"passed"`
	Runs           []ParsedRun `json:"runs"`
}

type SampleStatusSummary struct {
	SampleID           string  `json:"sample_id"`
	TotalParseable     int     `json:"total_parseable"`
	SuccessCount       int     `json:"success_count"`
	LowConfidenceCount int     `json:"low_confidence_count"`
	FailedCount        int     `json:"failed_count"`
	SuccessRate        float64 `json:"success_rate"`
	LowConfidenceRate  float64 `json:"low_confidence_rate"`
}

type LowConfidenceReasonRecord struct {
	SampleID string `json:"sample_id"`
	RunID    string `json:"run_id"`
	Reason   string `json:"reason"`
}

type TriStateReviewResult struct {
	Samples                    []SampleStatusSummary       `json:"samples"`
	LowConfidenceReasonRecords []LowConfidenceReasonRecord `json:"low_confidence_reason_records"`
	S1S2SuccessRate            float64                     `json:"s1_s2_success_rate"`
	S3LowConfidenceRate        float64                     `json:"s3_low_confidence_rate"`
	Threshold                  float64                     `json:"threshold"`
	Passed                     bool                        `json:"passed"`
}

type TimestampAccuracyRecord struct {
	SampleID      string `json:"sample_id"`
	RunID         string `json:"run_id"`
	ClipFound     bool   `json:"clip_found"`
	StartErrorMS  int    `json:"start_error_ms,omitempty"`
	EndErrorMS    int    `json:"end_error_ms,omitempty"`
	Within1Second bool   `json:"within_1s,omitempty"`
}

type TimestampAccuracyResult struct {
	Records         []TimestampAccuracyRecord `json:"records"`
	EvaluatedRuns   int                       `json:"evaluated_runs"`
	WithClipRuns    int                       `json:"with_clip_runs"`
	MissingClipRuns int                       `json:"missing_clip_runs"`
	MissingClipRate float64                   `json:"missing_clip_rate"`
	Within1SCount   int                       `json:"within_1s_count"`
	Within1SRate    float64                   `json:"within_1s_rate"`
	ThresholdMS     int                       `json:"threshold_ms"`
	Passed          bool                      `json:"passed"`
	Notes           []string                  `json:"notes,omitempty"`
}

type LatencyCostResult struct {
	TotalCalls         int      `json:"total_calls"`
	LatencyAverageMS   float64  `json:"latency_average_ms"`
	LatencyMinMS       int64    `json:"latency_min_ms"`
	LatencyMaxMS       int64    `json:"latency_max_ms"`
	LatencyThresholdMS int64    `json:"latency_threshold_ms"`
	LatencyPassed      bool     `json:"latency_passed"`
	CostAverageCNY     float64  `json:"cost_average_cny"`
	CostThresholdCNY   float64  `json:"cost_threshold_cny"`
	CostPassed         bool     `json:"cost_passed"`
	CallsWithCost      int      `json:"calls_with_cost"`
	MetricsFileFound   bool     `json:"metrics_file_found"`
	Notes              []string `json:"notes,omitempty"`
}

func ValidateOutputs(config ValidateConfig) error {
	runs, err := loadParsedRuns(config.ResponseRoot)
	if err != nil {
		return err
	}

	annotations, err := loadAnnotations(config.AnnotationsPath)
	if err != nil {
		return err
	}

	schema := buildSchemaCompliance(runs)
	tristate := buildTriStateReview(runs)
	timestamps := buildTimestampAccuracy(runs, annotations)
	latencyCost := buildLatencyCost(filepath.Join(config.ResponseRoot, "call_metrics.json"))

	if err := writeJSON(filepath.Join(config.ResultsRoot, "schema_compliance.json"), schema); err != nil {
		return err
	}
	if err := writeJSON(filepath.Join(config.ResultsRoot, "tristate_review.json"), tristate); err != nil {
		return err
	}
	if err := writeJSON(filepath.Join(config.ResultsRoot, "timestamp_accuracy.json"), timestamps); err != nil {
		return err
	}
	if err := writeJSON(filepath.Join(config.ResultsRoot, "latency_cost.json"), latencyCost); err != nil {
		return err
	}

	return nil
}

func loadParsedRuns(root string) ([]ParsedRun, error) {
	runs := []ParsedRun{}
	if _, err := os.Stat(root); err != nil {
		if os.IsNotExist(err) {
			return runs, nil
		}
		return nil, fmt.Errorf("stat response root: %w", err)
	}
	err := filepath.WalkDir(root, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if entry.IsDir() {
			return nil
		}
		if filepath.Ext(path) != ".json" {
			return nil
		}
		if filepath.Base(path) == "call_metrics.json" {
			return nil
		}

		content, err := os.ReadFile(path)
		if err != nil {
			return fmt.Errorf("read response file %s: %w", path, err)
		}
		runs = append(runs, parseRunFile(path, content))
		return nil
	})
	if err != nil {
		return nil, err
	}

	slices.SortFunc(runs, func(left ParsedRun, right ParsedRun) int {
		return strings.Compare(left.Path, right.Path)
	})
	return runs, nil
}

func parseRunFile(path string, content []byte) ParsedRun {
	run := ParsedRun{
		Path:     path,
		SampleID: filepath.Base(filepath.Dir(path)),
		RunID:    strings.TrimSuffix(filepath.Base(path), filepath.Ext(path)),
	}

	text := strings.TrimSpace(string(content))

	var recorded RecordedRun
	if err := json.Unmarshal(content, &recorded); err == nil && (recorded.SampleID != "" || recorded.RunID != "" || len(recorded.RawResponse) > 0 || recorded.ResponseText != "") {
		if recorded.SampleID != "" {
			run.SampleID = recorded.SampleID
		}
		if recorded.RunID != "" {
			run.RunID = recorded.RunID
		}
		if recorded.ResponseText != "" {
			text = recorded.ResponseText
		} else if len(recorded.RawResponse) > 0 {
			extracted, extractErr := ExtractResponseText(recorded.RawResponse)
			if extractErr != nil {
				run.ParseError = extractErr.Error()
				return run
			}
			text = extracted
		}
	}

	output, err := ParseAnalysisOutput(text)
	if err != nil {
		run.ParseError = err.Error()
		return run
	}

	run.Output = output
	run.ValidationErrors = validateAnalysisOutput(*output)
	return run
}

func validateAnalysisOutput(output AnalysisOutput) []string {
	errors := []string{}

	if !slices.Contains([]string{"success", "low_confidence", "failed"}, output.Status) {
		errors = append(errors, "status must be one of success, low_confidence, failed")
	}
	if strings.TrimSpace(output.OverallSummary) == "" {
		errors = append(errors, "overall_summary is required")
	}
	if strings.TrimSpace(output.MemoryCue) == "" {
		errors = append(errors, "memory_cue is required")
	}

	if output.Status == "success" && len(output.Feedbacks) == 0 {
		errors = append(errors, "feedbacks must contain at least one item when status=success")
	}
	if output.Status == "low_confidence" && strings.TrimSpace(output.LowConfidenceReason) == "" {
		errors = append(errors, "low_confidence_reason is required when status=low_confidence")
	}
	if output.Status == "success" && strings.TrimSpace(output.LowConfidenceReason) != "" {
		errors = append(errors, "low_confidence_reason must be empty when status=success")
	}

	for index, feedback := range output.Feedbacks {
		prefix := fmt.Sprintf("feedbacks[%d]", index)
		if feedback.Rank <= 0 {
			errors = append(errors, prefix+".rank must be a positive integer")
		}
		if strings.TrimSpace(feedback.Title) == "" {
			errors = append(errors, prefix+".title is required")
		}
		if strings.TrimSpace(feedback.Description) == "" {
			errors = append(errors, prefix+".description is required")
		}
		if strings.TrimSpace(feedback.HowToFix) == "" {
			errors = append(errors, prefix+".how_to_fix is required")
		}
		if strings.TrimSpace(feedback.Cue) == "" {
			errors = append(errors, prefix+".cue is required")
		}
		if !slices.Contains([]string{"high", "medium", "low"}, feedback.Severity) {
			errors = append(errors, prefix+".severity must be high, medium, or low")
		}
		if feedback.Clip != nil {
			if feedback.Clip.StartMS < 0 {
				errors = append(errors, prefix+".clip.start_ms must be non-negative")
			}
			if feedback.Clip.EndMS <= feedback.Clip.StartMS {
				errors = append(errors, prefix+".clip.end_ms must be greater than start_ms")
			}
		}
	}

	return errors
}

func buildSchemaCompliance(runs []ParsedRun) SchemaComplianceResult {
	result := SchemaComplianceResult{
		TotalRuns: len(runs),
		Threshold: 0.9,
		Runs:      runs,
	}
	for _, run := range runs {
		if run.ParseError == "" {
			result.ParseableRuns++
		}
		if run.ParseError == "" && len(run.ValidationErrors) == 0 {
			result.CompliantRuns++
		}
	}
	if result.TotalRuns > 0 {
		result.ComplianceRate = float64(result.CompliantRuns) / float64(result.TotalRuns)
	}
	result.Passed = result.TotalRuns > 0 && result.ComplianceRate >= result.Threshold
	return result
}

func buildTriStateReview(runs []ParsedRun) TriStateReviewResult {
	summaryBySample := map[string]*SampleStatusSummary{}
	reasons := []LowConfidenceReasonRecord{}

	s1s2Total := 0
	s1s2Success := 0
	s3Total := 0
	s3LowConfidence := 0

	for _, run := range runs {
		if run.ParseError != "" || run.Output == nil {
			continue
		}
		summary := summaryBySample[run.SampleID]
		if summary == nil {
			summary = &SampleStatusSummary{SampleID: run.SampleID}
			summaryBySample[run.SampleID] = summary
		}
		summary.TotalParseable++

		switch run.Output.Status {
		case "success":
			summary.SuccessCount++
			if run.SampleID == "s1" || run.SampleID == "s2" {
				s1s2Success++
			}
		case "low_confidence":
			summary.LowConfidenceCount++
			if run.SampleID == "s3" {
				s3LowConfidence++
			}
			reasons = append(reasons, LowConfidenceReasonRecord{
				SampleID: run.SampleID,
				RunID:    run.RunID,
				Reason:   run.Output.LowConfidenceReason,
			})
		case "failed":
			summary.FailedCount++
		}

		if run.SampleID == "s1" || run.SampleID == "s2" {
			s1s2Total++
		}
		if run.SampleID == "s3" {
			s3Total++
		}
	}

	samples := make([]SampleStatusSummary, 0, len(summaryBySample))
	for _, sampleID := range []string{"s1", "s2", "s3"} {
		if summary, ok := summaryBySample[sampleID]; ok {
			if summary.TotalParseable > 0 {
				summary.SuccessRate = float64(summary.SuccessCount) / float64(summary.TotalParseable)
				summary.LowConfidenceRate = float64(summary.LowConfidenceCount) / float64(summary.TotalParseable)
			}
			samples = append(samples, *summary)
		}
	}

	result := TriStateReviewResult{
		Samples:                    samples,
		LowConfidenceReasonRecords: reasons,
		Threshold:                  2.0 / 3.0,
	}
	if s1s2Total > 0 {
		result.S1S2SuccessRate = float64(s1s2Success) / float64(s1s2Total)
	}
	if s3Total > 0 {
		result.S3LowConfidenceRate = float64(s3LowConfidence) / float64(s3Total)
	}
	result.Passed = s1s2Total > 0 && s3Total > 0 && result.S1S2SuccessRate >= result.Threshold && result.S3LowConfidenceRate >= result.Threshold
	return result
}

func buildTimestampAccuracy(runs []ParsedRun, annotations map[string]SampleAnnotation) TimestampAccuracyResult {
	result := TimestampAccuracyResult{
		ThresholdMS: 1000,
	}

	for _, run := range runs {
		annotation, ok := annotations[run.SampleID]
		if !ok || run.ParseError != "" || run.Output == nil {
			continue
		}
		if annotation.ReferenceClip.EndMS <= annotation.ReferenceClip.StartMS {
			result.Notes = append(result.Notes, fmt.Sprintf("skip sample %s: annotation clip is not valid", run.SampleID))
			continue
		}
		result.EvaluatedRuns++

		record := TimestampAccuracyRecord{
			SampleID: run.SampleID,
			RunID:    run.RunID,
		}

		clip, found := selectReferenceClip(*run.Output, annotation.TargetFeedbackRank)
		if !found {
			record.ClipFound = false
			result.MissingClipRuns++
			result.Records = append(result.Records, record)
			continue
		}

		record.ClipFound = true
		result.WithClipRuns++
		record.StartErrorMS = int(math.Abs(float64(clip.StartMS - annotation.ReferenceClip.StartMS)))
		record.EndErrorMS = int(math.Abs(float64(clip.EndMS - annotation.ReferenceClip.EndMS)))
		record.Within1Second = record.StartErrorMS <= result.ThresholdMS && record.EndErrorMS <= result.ThresholdMS
		if record.Within1Second {
			result.Within1SCount++
		}
		result.Records = append(result.Records, record)
	}

	if result.EvaluatedRuns > 0 {
		result.MissingClipRate = float64(result.MissingClipRuns) / float64(result.EvaluatedRuns)
		result.Within1SRate = float64(result.Within1SCount) / float64(result.EvaluatedRuns)
	}
	result.Passed = result.EvaluatedRuns > 0 && result.Within1SRate >= (2.0/3.0)
	return result
}

func selectReferenceClip(output AnalysisOutput, targetRank int) (Clip, bool) {
	if targetRank > 0 {
		for _, feedback := range output.Feedbacks {
			if feedback.Rank == targetRank && feedback.Clip != nil {
				return *feedback.Clip, true
			}
		}
	}
	for _, feedback := range output.Feedbacks {
		if feedback.Clip != nil {
			return *feedback.Clip, true
		}
	}
	return Clip{}, false
}

func loadAnnotations(path string) (map[string]SampleAnnotation, error) {
	annotations := map[string]SampleAnnotation{}
	content, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return annotations, nil
		}
		return nil, fmt.Errorf("read annotations: %w", err)
	}
	if len(strings.TrimSpace(string(content))) == 0 {
		return annotations, nil
	}

	var document AnnotationDocument
	if err := json.Unmarshal(content, &document); err != nil {
		return nil, fmt.Errorf("parse annotations: %w", err)
	}
	for _, sample := range document.Samples {
		if strings.TrimSpace(sample.SampleID) == "" {
			continue
		}
		annotations[sample.SampleID] = sample
	}
	return annotations, nil
}

func buildLatencyCost(metricsPath string) LatencyCostResult {
	result := LatencyCostResult{
		LatencyThresholdMS: 30_000,
		CostThresholdCNY:   0.20,
	}

	content, err := os.ReadFile(metricsPath)
	if err != nil {
		result.Notes = append(result.Notes, "call_metrics.json not found")
		return result
	}
	result.MetricsFileFound = true

	metrics := []CallMetric{}
	if err := json.Unmarshal(content, &metrics); err != nil {
		result.Notes = append(result.Notes, "call_metrics.json is not valid JSON")
		return result
	}
	if len(metrics) == 0 {
		result.Notes = append(result.Notes, "call_metrics.json contains no calls")
		return result
	}

	result.TotalCalls = len(metrics)
	result.LatencyMinMS = metrics[0].LatencyMS
	result.LatencyMaxMS = metrics[0].LatencyMS

	var latencySum int64
	var costSum float64
	for _, metric := range metrics {
		latencySum += metric.LatencyMS
		if metric.LatencyMS < result.LatencyMinMS {
			result.LatencyMinMS = metric.LatencyMS
		}
		if metric.LatencyMS > result.LatencyMaxMS {
			result.LatencyMaxMS = metric.LatencyMS
		}
		if metric.EstimatedCostCNY != nil {
			costSum += *metric.EstimatedCostCNY
			result.CallsWithCost++
		}
	}

	result.LatencyAverageMS = float64(latencySum) / float64(result.TotalCalls)
	result.LatencyPassed = result.LatencyAverageMS <= float64(result.LatencyThresholdMS)
	if result.CallsWithCost > 0 {
		result.CostAverageCNY = costSum / float64(result.CallsWithCost)
		result.CostPassed = result.CostAverageCNY <= result.CostThresholdCNY
	} else {
		result.Notes = append(result.Notes, "no token usage returned; cost average not computed")
	}

	return result
}
