## Why

本地历史列表、动作筛选和详情页复用结果展示已经实现，但没有相应的 OpenSpec change 记录。需要补回流程，明确当前历史功能的范围与存储边界。

## What Changes

- 为本地历史功能补齐 OpenSpec 工件
- 记录历史列表、筛选、详情展示和本地存储边界
- 明确 MVP v1 历史不依赖后端云同步

## Capabilities

### New Capabilities
- `history-feature`: WinTrain MVP 的本地历史列表、筛选与详情查看能力

### Modified Capabilities

（无）

## Impact

- iOS：`ios/WinTrain/Views/HistoryView.swift`
- iOS：`ios/WinTrain/Views/HistoryDetailView.swift`
- iOS：`ios/WinTrain/Services/HistoryStore.swift`
- 文档：`docs/architecture/storage-models.md`
