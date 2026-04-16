# Spec: domain-models

## Purpose

定义 WinTrain MVP 的核心逻辑领域模型及其语义边界，不绑定具体数据库或本地持久化技术。

## Requirements

### Requirement: The system SHALL define stable logical models for core MVP entities
The system SHALL define logical models for device identity, analysis sessions, analysis results, subscriptions, and user-visible history records without binding those models to a specific storage technology.

#### Scenario: Analysis is represented in domain language
- **WHEN** product and engineering discuss one completed analysis
- **THEN** they can distinguish the session lifecycle object from the result payload object

#### Scenario: Storage implementation changes
- **WHEN** a storage implementation detail changes
- **THEN** the logical model semantics remain stable unless product behavior changes

### Requirement: User-visible history SHALL be modeled separately from raw processing state
The system SHALL represent user-facing history records as a distinct model from internal processing artifacts so local history can evolve without leaking backend internals into the UI.

#### Scenario: Client renders history list
- **WHEN** the iOS app loads local history
- **THEN** it uses user-visible history records rather than backend processing internals

#### Scenario: Backend processing includes additional internal metadata
- **WHEN** the backend stores or logs internal analysis metadata
- **THEN** that metadata does not have to appear in the user-visible history model
