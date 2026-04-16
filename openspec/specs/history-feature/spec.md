# Spec: history-feature

## Purpose

定义 WinTrain MVP 的本地历史列表、动作筛选与历史详情查看能力。

## Requirements

### Requirement: The iOS app SHALL provide local analysis history browsing
The iOS app SHALL provide a local analysis history experience that allows users to browse previously stored analysis results without requiring a backend history API.

#### Scenario: User opens history list
- **WHEN** the user navigates to the history screen
- **THEN** the app displays locally stored analysis history records

#### Scenario: User opens a history item
- **WHEN** the user selects a history record
- **THEN** the app displays that record's details using the result presentation flow

### Requirement: The history experience SHALL support action-based filtering
The local history experience SHALL support filtering by workout action type so users can narrow the visible records to a specific movement category.

#### Scenario: User filters by action
- **WHEN** the user selects an action filter
- **THEN** the history list updates to show only records matching that action

#### Scenario: User clears filters
- **WHEN** the user clears the selected action filter
- **THEN** the history list returns to the full set of locally stored records
