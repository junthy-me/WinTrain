## Context

该 change 对应 `recommended-first-changes.md` 中的 `003a-domain-models`。目前领域概念已经在文档和实现中存在，但缺少 OpenSpec 回填。

## Goals / Non-Goals

**Goals**
- 明确逻辑模型，不绑定具体数据库实现
- 说明分析结果、订阅状态和历史条目的语义关系

**Non-Goals**
- 不定义 PostgreSQL 表结构
- 不定义 Core Data / SQLite 具体 schema

## Decisions

### D1. 领域模型先于存储模型

逻辑模型定义“是什么”，存储模型定义“怎么存”。本 change 只处理前者。

### D2. 分析结果与会话生命周期分离

`AnalysisSession` 表示一次分析流程，`AnalysisResult` 表示该流程的用户可见结果，两者语义不同。

### D3. 历史记录是面向用户展示的聚合条目

`HistoryRecord` 不是 provider 原始输出，而是客户端本地展示所需的摘要化结果。

## Risks / Trade-offs

- 当前模型主要服务 MVP v1，未来支持更多动作或云同步时仍需演进

## Open Questions

- 未来多动作支持时是否需要进一步抽象训练模板
