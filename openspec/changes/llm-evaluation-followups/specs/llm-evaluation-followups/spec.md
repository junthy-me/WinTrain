## ADDED Requirements

### Requirement: The project SHALL track deferred model comparison work separately from the initial spike
The project SHALL track deferred model comparison work, including Gemini video-input evaluation, as a separate follow-up effort rather than leaving the initial spike indefinitely in-progress.

#### Scenario: Deferred comparison is needed
- **WHEN** the team decides to run a Gemini comparison
- **THEN** that work is executed under the dedicated follow-up change rather than the archived initial spike

#### Scenario: No immediate comparison is needed
- **WHEN** the MVP continues without Gemini comparison
- **THEN** the deferred work remains visible without blocking the initial spike archive

### Requirement: The project SHALL track post-spike optimization validation separately
The project SHALL track post-spike validation for schema stability, timestamp precision, and latency optimization as a separate follow-up effort.

#### Scenario: Prompt or provider optimization is attempted
- **WHEN** a later optimization experiment changes prompt strategy, provider choice, or preprocessing
- **THEN** the experiment results are recorded in the dedicated follow-up change

#### Scenario: Analysis-service needs updated guidance
- **WHEN** later experiments produce better validated constraints
- **THEN** the project can update LLM integration guidance without reopening the initial spike
