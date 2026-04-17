# Spec: result-display

## Purpose

定义 WinTrain MVP 的分析结果展示行为，包括结果页、历史详情复用与不同结果状态的呈现边界。

## Requirements

### Requirement: The iOS client SHALL present structured analysis results to the user
The iOS client SHALL present structured analysis outcomes in a dedicated result experience that reflects the backend response semantics and supports user review of analysis feedback.

#### Scenario: Successful analysis is shown
- **WHEN** the app receives a successful structured analysis result
- **THEN** it renders the result details in the dedicated result display

#### Scenario: User opens a stored result from history
- **WHEN** the user selects a previously stored analysis result from history
- **THEN** the app displays that result using the same result presentation semantics

### Requirement: The client SHALL preserve result-state distinctions in presentation
The client SHALL preserve the distinction between successful, low-confidence, and failed analysis outcomes in its result-related user messaging.

#### Scenario: Success with no issues found
- **WHEN** the analysis outcome is `status: success` and `feedbacks` is empty
- **THEN** the app presents a positive “动作优秀 / 继续保持” style result rather than forcing an error-focused view

#### Scenario: Success with only informational feedback
- **WHEN** the analysis outcome is `status: success` and all `feedbacks` are informational only
- **THEN** the app presents a “动作良好 / 继续保持” style result and SHALL NOT emphasize problem-correction details

#### Scenario: Low-confidence result
- **WHEN** the analysis outcome is low confidence
- **THEN** the app presents guidance that reflects the low-confidence state rather than a normal success presentation, using `low_confidence_reason` when available and showing exercise-specific shooting guidance

#### Scenario: Failed result
- **WHEN** the analysis outcome fails technically
- **THEN** the app presents an error-oriented state rather than displaying misleading analysis feedback, and SHALL NOT display exercise-specific shooting guidance
