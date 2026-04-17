## MODIFIED Requirements

### Requirement: The client SHALL preserve result-state distinctions in presentation
The client SHALL preserve the distinction between successful, low-confidence, and failed analysis outcomes in its result-related user messaging.

#### Scenario: Success with no issues found
- **WHEN** the analysis outcome is `status: success` and `feedbacks` is empty
- **THEN** the app presents a positive “动作优秀 / 继续保持” style result rather than forcing an error-focused view

#### Scenario: Low-confidence result
- **WHEN** the analysis outcome is `status: low_confidence`
- **THEN** the app presents a re-capture oriented result using `low_confidence_reason` when available, and displays exercise-specific shooting guidance

#### Scenario: Failed result
- **WHEN** the analysis outcome is `status: failed`
- **THEN** the app presents an error-oriented state and SHALL NOT display exercise-specific shooting guidance
