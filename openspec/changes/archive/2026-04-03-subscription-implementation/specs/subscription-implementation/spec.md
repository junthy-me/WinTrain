## ADDED Requirements

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
- **THEN** the change remains in-progress rather than being treated as production-complete

#### Scenario: Local StoreKit automation is unstable
- **WHEN** command-line StoreKit automation cannot complete because of Apple runtime entitlement issues
- **THEN** the project records that limitation and continues using manual local verification for non-blocking MVP progress
