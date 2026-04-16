## Why

后端和 iOS 本地存储的目标结构已经在架构文档中落地，但缺少单独的 OpenSpec change 对具体存储职责与生命周期进行记录。需要把这些已形成的决定补齐到流程中。

## What Changes

- 为后端 PostgreSQL 方向和 iOS 本地存储方向补齐 OpenSpec 工件
- 明确领域模型与存储模型的映射边界
- 记录数据生命周期与清理策略的 MVP 约束

## Capabilities

### New Capabilities
- `storage-models`: WinTrain MVP 的后端与 iOS 本地存储模型设计

### Modified Capabilities

（无）

## Impact

- 文档：`docs/architecture/storage-models.md`
- 文档：`docs/architecture/data-flow.md`
- iOS：本地历史存储实现
- 后端：未来数据库 schema 设计基础
