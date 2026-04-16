# Spec: subscription-implementation

## Purpose

定义 WinTrain MVP 中客户端发起订阅购买与恢复后的实现边界，包括 StoreKit 交易接入、后端激活调用，以及当前明确保留为后续工作的 Apple 生产集成缺口。

## Requirements

### Requirement: The system SHALL support client-initiated subscription activation and restore flows
The system SHALL support client-initiated purchase and restore flows using StoreKit and backend subscription APIs so the app can transition entitlement state after a successful transaction event.

#### Scenario: Client activates subscription after purchase
- **WHEN** the client receives a verified subscription transaction from StoreKit
- **THEN** it calls the backend subscription activation API with the required transaction identifiers

#### Scenario: Client restores existing subscription
- **WHEN** the user invokes restore purchases and a valid historical subscription is found
- **THEN** the client calls the backend restore path and refreshes local entitlement state

### Requirement: Incomplete Apple production integration SHALL remain explicit
The system SHALL keep real Apple validation and notification integration explicitly marked as incomplete until the required external resources and end-to-end verification are available.

#### Scenario: Real Apple resources are unavailable
- **WHEN** App Store Connect products or Apple validation credentials are unavailable
- **THEN** the project records that limitation in follow-up work rather than treating the MVP subscription implementation as production-complete

#### Scenario: Local StoreKit automation is unstable
- **WHEN** command-line StoreKit automation cannot complete because of Apple runtime entitlement issues
- **THEN** the project records that limitation and continues using manual local verification for non-blocking MVP progress
