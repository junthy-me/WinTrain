## MODIFIED Requirements

### Requirement: The backend SHALL orchestrate workout analysis through a dedicated analysis pipeline
The backend SHALL orchestrate video analysis through a dedicated pipeline that extracts frames, invokes an analysis provider, parses structured output, and returns a client-consumable result state. The pipeline SHALL support the following exercise IDs: `squat`、`lat-pulldown`、`bench-press`、`barbell-row`、`deadlift`。

#### Scenario: Analysis succeeds
- **WHEN** the provider returns valid structured output for the extracted frames
- **THEN** the backend returns a successful analysis result to the client

#### Scenario: Provider output is insufficient
- **WHEN** the provider response does not meet confidence or structure expectations
- **THEN** the backend returns a low-confidence outcome rather than a misleading success

#### Scenario: Unsupported exercise ID is rejected
- **WHEN** a request arrives with an `exercise_id` not in the supported list
- **THEN** the backend returns a 400 error with `invalid_exercise_id` code, without consuming quota

#### Scenario: Each supported exercise uses its dedicated prompt
- **WHEN** an analysis request arrives for a supported exercise ID
- **THEN** the provider is invoked with the exercise-specific system prompt for that ID
