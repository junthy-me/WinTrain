# WinTrain 推荐的第一批 OpenSpec Changes

**日期**: 2026-03-24
**最后更新**: 2026-03-24
**目的**: 从产品设计阶段过渡到工程实现阶段

---

## 使用说明

以下 Changes 按照依赖关系排序。每个 Change 的 Artifact 流程：
1. **Proposal** - 明确目标、范围、非目标
2. **Design** - 详细设计方案
3. **Tasks** - 可执行的任务列表
4. **Implementation** - 实际编码
5. **Verification** - 验证完成度

---

## 第一阶段：决策冻结

目标：在任何代码落地前，把所有会影响接口和数据结构的核心决策锁定。

### Change 001: 系统架构设计

**名称**: `001-system-architecture`

**目标**:
- 明确 iOS 客户端、Go 后端、LLM 服务之间的交互关系
- 定义模块边界与职责划分
- 确定视频上传路径（已决策：客户端直传后端）
- 确定数据流向

**输出物**:
- `docs/architecture/system-overview.md` - 系统架构图与说明
- `docs/architecture/module-boundaries.md` - 模块职责定义
- `docs/architecture/data-flow.md` - 数据流图

**阻塞**: 所有后续 Changes

---

### Change 004a: LLM 集成方案验证（Spike）

**名称**: `004a-llm-spike`

**目标**:
- 验证"后端抽关键帧 + Vision LLM"主路径的可行性
- 验证结构化输出格式（Q5 决策）的 LLM 稳定性
- 同步跑直接视频模型（Gemini）作为对照实验
- 输出可复用的 Prompt 模板和关键帧抽取策略

**为什么前移到 002 之前**:
API Contract 和数据模型的核心字段（分析结果结构、`severity`、`clip` 时间戳、`low_confidence` 状态）都依赖 LLM 实际输出形态。先做 Spike，确认 LLM 能稳定输出预期结构后，再定 Contract，避免返工。

**输出物**:
- `backend/poc/llm-spike/` - 概念验证代码
- `docs/architecture/llm-integration.md` - LLM 集成方案（关键帧策略、Prompt 模板、成本/延迟数据）

**验收标准**:
- 能稳定输出符合 Q5 决策格式的结构化 JSON
- 单次分析延迟 < 60 秒
- 在至少 2 个真实视频（深蹲 + 高位下拉各 1 个）上验证准确性
- 明确关键帧数量和抽帧策略

**依赖**: 001 完成

---

### Change 002: API Contract 定义

**名称**: `002-api-contracts`

**目标**:
- 定义 iOS 与 Go 后端之间的所有 API 接口
- 明确请求/响应格式（基于 Spike 验证后的分析结果结构）
- 定义错误码与错误处理
- 确保 Contract 稳定性

**输出物**:
- `docs/contracts/video-upload-api.md`
- `docs/contracts/analysis-api.md`（含 `status` 三态、`severity`、`clip` 时间戳）
- `docs/contracts/quota-api.md`
- `docs/contracts/subscription-api.md`
- `docs/contracts/error-codes.md`

**依赖**: 001、004a 完成

---

### Change 005: 权益与订阅设计

**名称**: `005-entitlement-and-subscription-design`

**目标**:
将设备身份、配额规则、订阅流程作为一个完整的权益系统统一设计，避免设计割裂。

**覆盖范围**:
- 设备身份：Keychain UUID（`install_id`）+ `originalTransactionId` 作为恢复锚点
- 免费次数规则：总计 3 次成功分析，每日最多 1 次
- 失败不计次的判定逻辑（`low_confidence` / `failed` 均不计次）
- 购买流程：StoreKit 2 集成方案
- 恢复购买流程：通过 `originalTransactionId` 关联设备
- 订阅失效/退款后的状态回退
- 客户端配额快照策略（5 分钟有效期、刷新时机）
- 服务端配额裁决的原子性保证

**输出物**:
- `docs/architecture/entitlement-system.md` - 权益系统完整设计
- `docs/architecture/subscription-flow.md` - 订阅状态机与流程图

**依赖**: 002 完成（需要知道 API Contract 中配额相关接口的形态）

---

### Change 003a: 领域模型设计

**名称**: `003a-domain-models`

**目标**:
定义逻辑数据模型，不绑定具体数据库或存储实现。

**覆盖范围**:
- `Device`：设备身份与配额状态
- `AnalysisSession`：一次分析的完整生命周期
- `AnalysisResult`：分析结果（含 `feedbacks[]`、`status`、`clip`）
- `Subscription`：订阅状态与有效期
- `HistoryRecord`：用户可见的历史记录条目

**不包含**:
- 数据库表结构（留给 003b）
- iOS 本地存储 Schema（留给 003b）
- 字段的存储类型（只定义语义类型）

**依赖**: 002、005 完成

---

### Change 003b: 存储模型设计

**名称**: `003b-storage-models`

**目标**:
在 Q9（订阅校验流程）和 Q10（历史记录存储位置）确认后，将领域模型映射到具体存储层。

**覆盖范围**:
- 后端数据库 Schema（PostgreSQL 表结构）
- iOS 本地存储 Schema（Core Data / SQLite）
- 数据生命周期与清理策略

**依赖**: 003a 完成，Q9/Q10 已确认

---

## 第二阶段：工程骨架

目标：搭建可运行的项目骨架，严格限定不碰业务实现。

**为什么提前到第一阶段之后立即启动**:
001 完成后，模块边界和技术选型已明确，iOS 和 Go 项目的骨架不依赖 Contract 细节，可以与 004a/002/005/003a 并行推进，节省时间。

### Change 006: iOS 项目初始化

**名称**: `006-ios-project-init`

**目标**:
- 创建 Xcode 项目（SwiftUI + iOS 16+）
- 配置项目目录结构（Models, Views, Services, Utils）
- 实现底部 Tab 导航骨架（首页、历史、我的）
- 封装网络请求基础层（URLSession + async/await）
- 配置 Keychain 工具类（为 install_id 做准备）

**严格非目标**:
- 不实现任何业务页面
- 不接入 StoreKit
- 不实现视频采集

**依赖**: 001 完成

---

### Change 007: Go 后端项目初始化

**名称**: `007-backend-project-init`

**目标**:
- 初始化 Go Module，选定 HTTP 框架（Gin / Echo）
- 配置项目目录结构（`cmd/`, `internal/`, `pkg/`）
- 实现 `GET /health` 接口
- 配置日志与错误处理中间件
- 编写 Dockerfile

**严格非目标**:
- 不实现任何业务接口
- 不连接数据库
- 不集成 LLM

**依赖**: 001 完成

---

## 第三阶段：核心闭环

目标：打通"上传 → 分析 → 展示"完整链路。

### Change 008: 视频上传功能

**名称**: `008-video-upload`

**目标**:
- iOS 实现视频录制与上传（含进度展示、超时重试）
- 后端实现视频接收（含文件大小校验、格式校验）

**依赖**: 002、006、007 完成

---

### Change 009: 动作分析服务

**名称**: `009-analysis-service`

**目标**:
- 后端实现关键帧抽取
- 后端实现 LLM 调用与结构化输出解析
- 实现分析任务编排（含超时、重试、`low_confidence` 判定）

**依赖**: 002、004a、007 完成

---

### Change 010: 配额系统实现

**名称**: `010-quota-implementation`

**目标**:
- 后端实现配额裁决逻辑（原子性扣减、每日限制、总次数限制）
- 后端实现 `GET /v1/quota` 接口
- iOS 实现配额快照缓存与展示

**依赖**: 005、003a、006、007 完成

---

### Change 011: 分析结果展示

**名称**: `011-result-display`

**目标**:
- iOS 实现结果页 UI（含 `low_confidence` 降级展示）
- 实现保存到本地历史记录

**非目标**:
仅保存本地最小历史视图模型，不在该 change 中实现完整历史记录功能。

**依赖**: 002、006、009 完成

---

## 第四阶段：商业化与留存

目标：完成订阅支付和历史记录功能，达到可发布状态。

### Change 012: 订阅支付实现

**名称**: `012-subscription-implementation`

**目标**:
- iOS 集成 StoreKit 2（购买、恢复购买）
- 后端实现订阅校验（Apple Server-to-Server 通知 or receipt 验证）
- 实现订阅失效/退款后的状态回退

**依赖**: 005、003b、006、007 完成

---

### Change 013: 历史记录功能

**名称**: `013-history-feature`

**目标**:
- iOS 实现历史记录列表（按动作筛选、日期筛选）
- 实现历史详情查看（复用结果页）

**依赖**: 003b、006、011 完成

---

### 集成测试 / 冒烟 / 修复

按照 `docs/testing-strategy.md` 执行：
- Contract 测试
- 领域测试（Session 生命周期、权益判断、配额逻辑）
- 集成测试（完整链路）
- 人工冒烟测试（关键路径）

---

## 依赖关系图

```
001-system-architecture
├── 004a-llm-spike
│   └── 002-api-contracts
│       ├── 005-entitlement-and-subscription-design
│       │   └── 003a-domain-models
│       │       └── 003b-storage-models (等 Q9/Q10 确认)
│       └── (解锁第三阶段)
├── 006-ios-project-init (并行)
└── 007-backend-project-init (并行)

第三阶段（需 002 + 006 + 007 完成）:
008-video-upload → 009-analysis-service → 011-result-display
010-quota-implementation (需 005 + 003a)

第四阶段（需第三阶段完成）:
012-subscription-implementation
013-history-feature
```

---

## 风险提示

**最高风险**: Change 004a（LLM Spike）
- LLM 输出结构化 JSON 的稳定性不确定，可能需要多轮 Prompt 调优
- 如果 Spike 结果显示 Q5 决策的格式需要调整，需要在 002 之前完成修订

**次高风险**: Change 012（订阅支付）
- Apple 审核对订阅功能有额外要求，需提前熟悉 App Store Review Guidelines
- StoreKit 2 沙盒测试环境配置复杂，建议提前准备
