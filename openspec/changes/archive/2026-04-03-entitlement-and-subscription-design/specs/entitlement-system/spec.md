## ADDED Requirements

### Requirement: The system SHALL maintain a unified entitlement model
The system SHALL model free quota, subscription state, device identity, and restore anchors as one entitlement system so quota decisions and subscription behavior remain coherent across iOS and backend components.

#### Scenario: Device requests current quota
- **WHEN** the iOS client requests the current quota snapshot
- **THEN** the backend returns entitlement-related free quota and subscription status based on the server-side source of truth

#### Scenario: Client displays cached entitlement state
- **WHEN** the client has a recent cached quota snapshot
- **THEN** it MAY render that snapshot for UI messaging but SHALL still rely on the backend for final analysis authorization

### Requirement: Free quota SHALL only decrement on successful analysis
The system SHALL decrement free quota only when an analysis completes with `status: success`, and SHALL NOT decrement quota for `low_confidence` or `failed` outcomes.

#### Scenario: Successful analysis consumes quota
- **WHEN** an analysis returns `success`
- **THEN** the backend decrements the free quota according to the configured policy

#### Scenario: Low-confidence analysis does not consume quota
- **WHEN** an analysis returns `low_confidence`
- **THEN** the backend preserves the user's remaining free quota

### Requirement: Subscription restore SHALL be anchored by original transaction identity
The system SHALL use `originalTransactionId` as the stable restore anchor for subscription recovery and backend entitlement linkage.

#### Scenario: Purchase activation
- **WHEN** the client receives a verified StoreKit transaction
- **THEN** it sends the transaction data including `originalTransactionId` to the backend subscription activation API

#### Scenario: Restore purchase
- **WHEN** the client performs a restore flow for an existing subscription
- **THEN** the backend resolves entitlement state using the restored `originalTransactionId`
