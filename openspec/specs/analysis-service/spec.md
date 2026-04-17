# Spec: analysis-service

## Purpose

定义 WinTrain MVP 的分析服务编排，包括关键帧抽取、provider 调用、结构化解析与结果状态映射。

## Requirements

### Requirement: The backend SHALL orchestrate workout analysis through a dedicated analysis pipeline
The backend SHALL orchestrate video analysis through a dedicated pipeline that extracts frames, invokes an analysis provider, parses structured output, and returns a client-consumable result state.

#### Scenario: Analysis succeeds
- **WHEN** the provider returns valid structured output for the extracted frames
- **THEN** the backend returns a successful analysis result to the client

#### Scenario: Success result with no major issues found
- **WHEN** the provider returns a confident structured result and finds no issue that requires focused correction
- **THEN** the backend returns `status: success` with `feedbacks: []` and a non-empty `overall_summary`

#### Scenario: Provider output is insufficient
- **WHEN** the provider response does not meet confidence or structure expectations
- **THEN** the backend returns a low-confidence outcome rather than a misleading success

#### Scenario: Status field is missing but low-confidence reason is present
- **WHEN** the provider output omits `status` or returns an invalid `status`, and `low_confidence_reason` is non-empty
- **THEN** the backend SHALL normalize the result to `status: low_confidence`

#### Scenario: Status field is missing but structured success body is otherwise complete
- **WHEN** the provider output omits `status` or returns an invalid `status`, and the result has a non-empty `overall_summary`, a valid `feedbacks` array, and no `low_confidence_reason`
- **THEN** the backend MAY normalize the result to `status: success`

#### Scenario: Status field is missing and the body is not structurally sufficient
- **WHEN** the provider output omits `status` or returns an invalid `status`, and the remaining structured fields are insufficient to support success or low-confidence semantics
- **THEN** the backend SHALL normalize the result to `status: failed`

#### Scenario: Each supported exercise uses its dedicated prompt
- **WHEN** an analysis request arrives for a supported exercise ID
- **THEN** the provider is invoked with the exercise-specific system prompt for that ID

### Requirement: The analysis pipeline SHALL support interchangeable provider implementations
The analysis pipeline SHALL support interchangeable provider implementations so local development and production-like execution can use different backends without changing the API contract.

#### Scenario: Local development
- **WHEN** local development runs without a production provider
- **THEN** the backend can use a mock provider through the same analysis service abstraction

#### Scenario: OpenAI-compatible execution
- **WHEN** a configured OpenAI-compatible provider is available
- **THEN** the backend can invoke it through the same analysis service abstraction
