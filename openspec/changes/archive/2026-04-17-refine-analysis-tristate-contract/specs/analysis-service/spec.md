## MODIFIED Requirements

### Requirement: The backend SHALL orchestrate workout analysis through a dedicated analysis pipeline
The backend SHALL orchestrate video analysis through a dedicated pipeline that extracts frames, invokes an analysis provider, parses structured output, and returns a client-consumable result state.

#### Scenario: Success result with actionable issues
- **WHEN** the provider returns a confident structured result and identifies one or more reliable issues
- **THEN** the backend returns `status: success` with non-empty `feedbacks`

#### Scenario: Success result with no major issues found
- **WHEN** the provider returns a confident structured result and finds no issue that requires focused correction
- **THEN** the backend returns `status: success` with `feedbacks: []` and a non-empty `overall_summary`

#### Scenario: Status field is missing but low-confidence reason is present
- **WHEN** the provider output omits `status` or returns an invalid `status`, and `low_confidence_reason` is non-empty
- **THEN** the backend SHALL normalize the result to `status: low_confidence`

#### Scenario: Status field is missing but structured success body is otherwise complete
- **WHEN** the provider output omits `status` or returns an invalid `status`, and the result has a non-empty `overall_summary`, a valid `feedbacks` array, and no `low_confidence_reason`
- **THEN** the backend MAY normalize the result to `status: success`

#### Scenario: Status field is missing and the body is not structurally sufficient
- **WHEN** the provider output omits `status` or returns an invalid `status`, and the remaining structured fields are insufficient to support success or low-confidence semantics
- **THEN** the backend SHALL normalize the result to `status: failed`
