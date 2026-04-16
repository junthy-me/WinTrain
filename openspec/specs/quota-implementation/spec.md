# Spec: quota-implementation

## Purpose

定义 WinTrain MVP 的免费额度裁决与客户端配额快照展示行为。

## Requirements

### Requirement: The backend SHALL perform authoritative quota decisions
The backend SHALL make the authoritative decision on whether an analysis request may proceed and SHALL update quota state according to the configured free usage rules.

#### Scenario: Request allowed
- **WHEN** a user still has remaining free usage or an active subscription
- **THEN** the backend allows analysis to proceed

#### Scenario: Request denied
- **WHEN** a user has exhausted free usage and lacks active subscription entitlement
- **THEN** the backend rejects the analysis request with the documented quota exhaustion response

### Requirement: The client SHALL maintain a display-oriented quota snapshot
The iOS client SHALL maintain a display-oriented quota snapshot that can be refreshed from the backend and reused for short-lived UI rendering.

#### Scenario: App refreshes quota state
- **WHEN** the app requests the quota endpoint
- **THEN** it stores the returned snapshot for later UI display

#### Scenario: Non-success analysis finishes
- **WHEN** an analysis finishes as `low_confidence` or `failed`
- **THEN** the client-visible quota snapshot remains consistent with no additional free usage decrement
