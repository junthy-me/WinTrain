# Spec: ios-visual-parity

## Purpose

定义 iOS SwiftUI 客户端在首页、拍摄、分析、结果、历史、我的和订阅页上的 FE 风格视觉壳层与状态映射规则。

## Requirements

### Requirement: The iOS client SHALL provide an FE-aligned application shell
The iOS client SHALL present the primary MVP experience inside a custom SwiftUI shell that matches the FE visual structure, including dark theme surfaces, branded headers, and a persistent bottom navigation for the main areas.

#### Scenario: User opens the app
- **WHEN** the user launches the iOS app
- **THEN** the app shows the primary experience inside the FE-aligned dark visual shell instead of a plain system list layout

#### Scenario: User switches between primary areas
- **WHEN** the user navigates between home, capture, history, and profile areas
- **THEN** the app preserves the FE-aligned bottom navigation styling and selected-state feedback

### Requirement: The iOS client SHALL preserve existing MVP flows while matching FE presentation
The iOS client SHALL render the home, exercise selection, guide, analyzing, result, history, profile, and paywall experiences using FE-equivalent layout hierarchy, CTA placement, and state grouping without changing the existing business behavior of those flows.

#### Scenario: User performs an analysis flow
- **WHEN** the user moves from action selection through guide, analysis, and result
- **THEN** the app presents each step with FE-aligned layout and status presentation while keeping the existing analysis submission and result semantics

#### Scenario: User opens subscription and history experiences
- **WHEN** the user enters history, profile, or paywall from the iOS app
- **THEN** the app presents those screens with FE-aligned sections, badges, and actions while preserving current local data and subscription operations

### Requirement: The iOS client SHALL map runtime states into FE-style visual states
The iOS client SHALL translate quota state, success or low-confidence analysis state, failed analysis state, and subscription state into FE-style cards, badges, helper text, and empty states without obscuring the underlying runtime condition.

#### Scenario: Analysis succeeds or returns low confidence
- **WHEN** the app receives a completed analysis result
- **THEN** it shows a result presentation whose copy and styling reflect the runtime result state and actionable guidance

#### Scenario: Analysis cannot produce a usable result
- **WHEN** the analysis flow fails or returns a technically unusable result
- **THEN** the app shows the FE-style failure state with retry guidance and without misrepresenting the result as success
