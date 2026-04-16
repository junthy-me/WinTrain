## ADDED Requirements

### Requirement: The system SHALL support production Apple subscription validation before release
The system SHALL complete real Apple subscription validation and notification handling before the subscription flow can be treated as production-ready.

#### Scenario: Production receipt validation
- **WHEN** a real StoreKit transaction is created in production or sandbox
- **THEN** the backend validates it using the selected Apple integration strategy before treating the entitlement as production-ready

#### Scenario: Notification-based state update
- **WHEN** Apple sends a subscription state change notification
- **THEN** the backend can process that notification to update entitlement state correctly

### Requirement: The project SHALL stabilize local subscription verification workflows
The project SHALL provide at least one reliable local verification workflow for purchase, restore, renewal, and refund scenarios before considering the Apple subscription flow fully verified.

#### Scenario: Manual local verification
- **WHEN** Xcode local StoreKit testing is used manually
- **THEN** purchase, restore, renewal, and refund scenarios can be exercised and observed

#### Scenario: Automated local verification
- **WHEN** command-line StoreKit automation is available without entitlement errors
- **THEN** the project can run repeatable automated subscription verification scenarios
