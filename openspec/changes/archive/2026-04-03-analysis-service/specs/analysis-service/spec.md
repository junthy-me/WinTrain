## ADDED Requirements

### Requirement: The backend SHALL orchestrate workout analysis through a dedicated analysis pipeline
The backend SHALL orchestrate video analysis through a dedicated pipeline that extracts frames, invokes an analysis provider, parses structured output, and returns a client-consumable result state.

#### Scenario: Analysis succeeds
- **WHEN** the provider returns valid structured output for the extracted frames
- **THEN** the backend returns a successful analysis result to the client

#### Scenario: Provider output is insufficient
- **WHEN** the provider response does not meet confidence or structure expectations
- **THEN** the backend returns a low-confidence outcome rather than a misleading success

### Requirement: The analysis pipeline SHALL support interchangeable provider implementations
The analysis pipeline SHALL support interchangeable provider implementations so local development and production-like execution can use different backends without changing the API contract.

#### Scenario: Local development
- **WHEN** local development runs without a production provider
- **THEN** the backend can use a mock provider through the same analysis service abstraction

#### Scenario: OpenAI-compatible execution
- **WHEN** a configured OpenAI-compatible provider is available
- **THEN** the backend can invoke it through the same analysis service abstraction
