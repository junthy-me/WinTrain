## ADDED Requirements

### Requirement: Backend SHALL expose stable MVP analysis APIs
The system SHALL expose stable HTTP APIs for video upload, analysis submission, quota retrieval, and subscription activation that match the documented request and response structures used by the iOS client.

#### Scenario: Client submits an analysis request
- **WHEN** the iOS client submits a valid analysis request with device identity and video payload
- **THEN** the backend returns a structured analysis response or a structured error response using the documented contract

#### Scenario: Client requests quota snapshot
- **WHEN** the iOS client calls the quota endpoint
- **THEN** the backend returns the current remaining quota snapshot and subscription state in the documented format

### Requirement: Analysis responses SHALL preserve tri-state semantics
The analysis contract SHALL distinguish `success`, `low_confidence`, and `failed` as separate result states, and each state SHALL carry the fields required by the client for user messaging and quota handling.

#### Scenario: Successful analysis response
- **WHEN** the backend completes an analysis with confident structured output
- **THEN** it returns `status: success` with structured feedback items and clip metadata

#### Scenario: Low-confidence analysis response
- **WHEN** the backend determines the result is not reliable enough for user feedback
- **THEN** it returns `status: low_confidence` without treating the request as a billable success

#### Scenario: Technical failure response
- **WHEN** the backend cannot complete analysis because of processing or provider failure
- **THEN** it returns `status: failed` or a documented error code that the client can map to retry behavior

### Requirement: Error handling SHALL use documented machine-readable codes
The API contract SHALL define machine-readable error codes for quota exhaustion, validation failure, upload failure, and subscription-related failures so the client can render consistent behavior.

#### Scenario: Quota exhaustion
- **WHEN** a client submits an analysis request after exhausting allowed free usage
- **THEN** the backend returns the documented quota exhaustion error code instead of a generic server error

#### Scenario: Invalid request payload
- **WHEN** a client submits a malformed or unsupported request
- **THEN** the backend returns a documented validation error code and message shape
