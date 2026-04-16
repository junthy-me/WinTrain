## Why

WinTrain MVP 的产品定义已完成，前端原型已实现，但 iOS 客户端和 Go 后端均尚未启动。在进入工程实现前，必须先明确系统各组件之间的边界、交互方式和数据流向，否则 iOS 和后端无法协作开发，API Contract 也无法定义。

## What Changes

- 新增系统架构概览文档，明确 iOS 客户端、Go 后端、LLM 服务三者的关系与交互方式
- 新增模块边界文档，定义各模块的职责范围，防止职责蔓延
- 新增数据流文档，描述"视频上传 → 分析 → 结果返回 → 本地存储"的完整数据流向
- 确定以下系统级决策（均为 MVP v1 范围）：
  - 视频上传路径：客户端直传后端，Contract 预留切换对象存储能力
  - 后端部署形态：单体 Go 服务 + Docker，部署在 VPS
  - 视频存储策略：分析完成后后端不持久化视频，端侧优先
  - 历史记录存储位置：MVP v1 存储在 iOS 本地（Core Data），后端不提供历史查询 API

## Capabilities

### New Capabilities

- `system-architecture`: 系统整体架构，包含组件关系图、交互方式、部署形态
- `module-boundaries`: 各模块（iOS 客户端、Go 后端、LLM 服务）的职责边界定义
- `data-flow`: 核心业务数据流（视频上传、分析、结果、历史记录）

### Modified Capabilities

（无，当前 openspec/specs/ 为空，无已有规范需要修改）

## Impact

**文档输出**（本 change 不产生代码）:
- `docs/architecture/system-overview.md`
- `docs/architecture/module-boundaries.md`
- `docs/architecture/data-flow.md`

**解锁的后续工作**:
- `004a-llm-spike`：需要知道后端分析管道的位置和关键帧抽取的职责归属
- `002-api-contracts`：需要系统架构确定后才能定义接口边界
- `006-ios-project-init` / `007-backend-project-init`：需要模块边界确定后才能搭建项目骨架

**本 change 不涉及**:
- 任何代码实现
- API 接口字段定义（属于 002-api-contracts）
- LLM Prompt 设计（属于 004a-llm-spike）
- 数据库 Schema（属于 003b-storage-models）
- 订阅与权益逻辑（属于 005-entitlement-and-subscription-design）
