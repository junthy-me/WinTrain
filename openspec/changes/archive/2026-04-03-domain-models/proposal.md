## Why

MVP 的设备、分析、订阅、历史等概念已经在文档和代码中形成稳定结构，但没有独立的 OpenSpec change 记录这些领域模型语义。需要补齐这一层，给存储设计和后续验证一个清晰边界。

## What Changes

- 为现有逻辑数据模型补齐 OpenSpec 工件
- 固化 `Device`、`AnalysisSession`、`AnalysisResult`、`Subscription`、`HistoryRecord` 的语义边界
- 使领域模型与存储模型、接口模型分层清晰

## Capabilities

### New Capabilities
- `domain-models`: WinTrain MVP 的逻辑数据模型与语义边界

### Modified Capabilities

（无）

## Impact

- 文档：`docs/architecture/domain-models.md`
- 文档：`docs/architecture/system-overview.md`
- iOS：`ios/WinTrain/Models/AppModels.swift`
- 后端：`backend/internal/analysis/`
