package spike

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"strings"
)

var codeFenceJSONPattern = regexp.MustCompile("(?s)```(?:json)?\\s*(\\{.*\\})\\s*```")

func ExtractResponseText(raw []byte) (string, error) {
	var envelope ChatCompletionsResponse
	if err := json.Unmarshal(raw, &envelope); err != nil {
		return "", err
	}
	if len(envelope.Choices) == 0 {
		return "", errors.New("response has no choices")
	}

	content := bytes.TrimSpace(envelope.Choices[0].Message.Content)
	if len(content) == 0 {
		return "", errors.New("response content is empty")
	}

	var asString string
	if err := json.Unmarshal(content, &asString); err == nil {
		return asString, nil
	}

	var asParts []map[string]any
	if err := json.Unmarshal(content, &asParts); err == nil {
		var builder strings.Builder
		for _, part := range asParts {
			if text, ok := part["text"].(string); ok {
				builder.WriteString(text)
			}
		}
		if builder.Len() > 0 {
			return builder.String(), nil
		}
	}

	return "", errors.New("response content is not a supported text shape")
}

func ParseAnalysisOutput(rawText string) (*AnalysisOutput, error) {
	jsonBytes, err := ExtractJSONObject(rawText)
	if err != nil {
		return nil, err
	}

	var output AnalysisOutput
	if err := json.Unmarshal(jsonBytes, &output); err != nil {
		return nil, err
	}
	return &output, nil
}

func ExtractJSONObject(rawText string) ([]byte, error) {
	trimmed := strings.TrimSpace(rawText)
	if trimmed == "" {
		return nil, errors.New("text is empty")
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

	start := -1
	depth := 0
	inString := false
	escaped := false
	for index := 0; index < len(trimmed); index++ {
		ch := trimmed[index]
		if inString {
			if escaped {
				escaped = false
				continue
			}
			switch ch {
			case '\\':
				escaped = true
			case '"':
				inString = false
			}
			continue
		}

		switch ch {
		case '"':
			inString = true
		case '{':
			if depth == 0 {
				start = index
			}
			depth++
		case '}':
			if depth == 0 {
				continue
			}
			depth--
			if depth == 0 && start >= 0 {
				candidate := trimmed[start : index+1]
				if json.Valid([]byte(candidate)) {
					return []byte(candidate), nil
				}
			}
		}
	}

	return nil, fmt.Errorf("no valid JSON object found in response")
}
