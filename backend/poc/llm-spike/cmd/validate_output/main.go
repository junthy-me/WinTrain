package main

import (
	"flag"
	"fmt"
	"os"

	"wintrain/backend/poc/llm-spike/internal/spike"
)

func main() {
	var (
		responseRoot = flag.String("responses", "poc/llm-spike/testdata/llm_responses", "root directory containing saved LLM responses")
		annotations  = flag.String("annotations", "poc/llm-spike/testdata/annotations.json", "path to the human annotation file")
		resultsRoot  = flag.String("results", "poc/llm-spike/results", "directory for generated summary JSON files")
	)
	flag.Parse()

	config := spike.ValidateConfig{
		ResponseRoot:    *responseRoot,
		AnnotationsPath: *annotations,
		ResultsRoot:     *resultsRoot,
	}
	if err := spike.ValidateOutputs(config); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Printf("wrote %s/schema_compliance.json\n", config.ResultsRoot)
	fmt.Printf("wrote %s/tristate_review.json\n", config.ResultsRoot)
	fmt.Printf("wrote %s/timestamp_accuracy.json\n", config.ResultsRoot)
	fmt.Printf("wrote %s/latency_cost.json\n", config.ResultsRoot)
}
