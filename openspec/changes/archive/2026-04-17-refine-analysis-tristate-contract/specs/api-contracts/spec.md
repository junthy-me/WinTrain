## MODIFIED Requirements

### Requirement: Analysis responses SHALL preserve tri-state semantics
The analysis contract SHALL distinguish `success`, `low_confidence`, and `failed` as separate result states, and each state SHALL carry the fields required by the client for user messaging and quota handling.

#### Scenario: Successful analysis with no issues
- **WHEN** the backend completes a confident analysis and finds no issue that requires focused correction
- **THEN** it returns `status: success`, a non-empty `overall_summary`, and `feedbacks: []`

#### Scenario: Low-confidence analysis response
- **WHEN** the backend determines the result is not reliable enough for user feedback
- **THEN** it returns `status: low_confidence` with a non-empty `low_confidence_reason`

#### Scenario: Failed analysis response
- **WHEN** the backend cannot produce a reliable structured result because of provider or processing failure
- **THEN** it returns `status: failed` with a non-empty `overall_summary` and `feedbacks: []`
