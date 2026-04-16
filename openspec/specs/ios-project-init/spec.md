# Spec: ios-project-init

## Purpose

定义 WinTrain iOS 客户端的工程初始化与基础应用骨架，包括项目结构、导航壳和共享基础设施。

## Requirements

### Requirement: The system SHALL provide an iOS application shell for the MVP
The system SHALL provide an iOS application shell with a runnable SwiftUI project, base navigation structure, and foundational services needed by later MVP features.

#### Scenario: Developer builds the iOS app
- **WHEN** a developer generates and builds the iOS project
- **THEN** the app project compiles and launches with the base application shell

#### Scenario: User opens the app
- **WHEN** the app starts
- **THEN** the user can access the primary navigation areas through the base tab structure

### Requirement: The iOS shell SHALL include reusable client infrastructure
The iOS shell SHALL include reusable client infrastructure for networking, local device identity, local state storage, and environment wiring so later feature changes do not need to reintroduce those primitives.

#### Scenario: Feature code needs device identity
- **WHEN** a feature requires device identity
- **THEN** it can retrieve that identity through the shared install ID infrastructure

#### Scenario: Feature code needs API access
- **WHEN** a feature needs to call the backend
- **THEN** it can do so through the shared network service layer
