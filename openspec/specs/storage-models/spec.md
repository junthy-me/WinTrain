# Spec: storage-models

## Purpose

定义 WinTrain MVP 的后端与 iOS 本地存储模型边界，以及临时处理数据与长期数据的生命周期约束。

## Requirements

### Requirement: The system SHALL separate local user history storage from backend operational storage
The system SHALL store user-visible analysis history locally on iOS for MVP v1, while backend storage SHALL be limited to operational and entitlement-related data needed by the service.

#### Scenario: User browses history on device
- **WHEN** the user opens the history screen
- **THEN** the app loads history from local storage without requiring a backend history query API

#### Scenario: Backend keeps operational records
- **WHEN** the backend processes an analysis or entitlement event
- **THEN** it stores only the data required for service operation rather than the full user history experience

### Requirement: Video processing artifacts SHALL be temporary
The system SHALL treat uploaded video files and derived processing artifacts as temporary data and SHALL clear them after analysis completes unless a later change explicitly adds long-term retention.

#### Scenario: Analysis completes successfully
- **WHEN** the backend finishes analysis
- **THEN** temporary video processing files are eligible for cleanup and are not retained as part of long-term user history

#### Scenario: Analysis fails technically
- **WHEN** the backend fails during processing
- **THEN** temporary artifacts are still cleaned up according to the temporary storage policy
