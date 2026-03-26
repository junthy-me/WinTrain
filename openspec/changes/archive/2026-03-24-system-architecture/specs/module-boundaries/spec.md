## ADDED Requirements

### Requirement: iOS 客户端职责边界
iOS 客户端 SHALL 负责且仅负责以下职责：视频录制与上传、全部 UI 与页面状态管理、本地历史记录存储、订阅购买（StoreKit 2）、配额状态缓存展示、设备标识（Keychain UUID）。

iOS 客户端 SHALL NOT 执行以下操作：直接调用 LLM API、在本地执行配额裁决、将原始视频持久化到本地历史记录（历史记录仅保存派生片段引用）、持久化用户视频到云端。

#### Scenario: 客户端展示配额状态
- **WHEN** iOS 客户端展示剩余免费次数
- **THEN** 展示内容 SHALL 来自服务端返回的配额快照，客户端不得自行计算配额

#### Scenario: 客户端尝试直接调用 LLM
- **WHEN** 任何代码路径试图从 iOS 客户端直接调用 LLM API
- **THEN** 该行为 SHALL 被视为架构违规，不得合并

---

### Requirement: Go 后端职责边界
Go 后端 SHALL 负责且仅负责以下职责：接收视频并触发分析任务、关键帧抽取、LLM 调用与结构化输出解析、配额裁决（服务端最终权威）、订阅校验、操作日志记录、权益状态维护。

Go 后端 SHALL NOT 执行以下操作：持久化用户视频、在响应中返回视频二进制数据、执行 iOS 端的 UI 逻辑。

#### Scenario: 后端执行配额裁决
- **WHEN** iOS 客户端提交分析请求
- **THEN** 后端 SHALL 在启动分析流程前检查配额，配额不足时 SHALL 返回明确的 entitlement/quota 错误（具体错误码由 002-api-contracts 定义），不启动分析

#### Scenario: 后端记录操作日志
- **WHEN** 任意分析请求完成（无论成功、low_confidence 或 failed）
- **THEN** 后端 SHALL 记录包含 install_id、动作类型、分析状态、时间戳的操作日志，不记录视频内容

---

### Requirement: LLM 服务职责边界
LLM Vision 服务（第三方）SHALL 仅接收关键帧图片序列和 Prompt，返回结构化 JSON 格式的动作分析结果。后端 SHALL 将 LLM 调用封装在独立的接口层，以便切换服务商。

#### Scenario: LLM 服务商切换
- **WHEN** 需要将 LLM 服务商从 A 切换到 B
- **THEN** 修改范围 SHALL 仅限于后端 LLM 调用适配层，不影响 iOS 客户端和 API Contract

---

### Requirement: 历史记录存储在 iOS 本地
MVP v1 的用户历史记录 SHALL 存储在 iOS 设备本地（Core Data）。历史记录 SHALL 仅保存以下内容：结构化分析结果、必要展示字段、本地派生片段引用。历史记录 SHALL NOT 保存完整原始视频。

分析结果三态对历史记录的影响：
- `success`：SHALL 写入正式历史记录，历史详情页 SHALL 支持代表性片段回放（播放本地派生片段）
- `low_confidence`：SHALL NOT 写入历史记录，仅用于当前会话的重拍引导
- `failed`：SHALL NOT 写入历史记录，仅用于当前会话的错误提示与重试

后端 SHALL NOT 提供历史记录查询 API。后端的操作日志与用户可见的历史记录 SHALL 分离，互不依赖。

#### Scenario: 用户查看历史记录
- **WHEN** 用户打开历史记录页面
- **THEN** 数据 SHALL 从 iOS 本地存储读取，不发起网络请求

#### Scenario: 用户查看历史详情并回放片段
- **WHEN** 用户点击某条 status=success 的历史记录查看详情
- **THEN** iOS 客户端 SHALL 直接播放该记录对应的本地派生片段；若派生片段文件不存在，SHALL 展示"片段不可用"提示

#### Scenario: 用户换设备后查看历史
- **WHEN** 用户在新设备上安装应用
- **THEN** 历史记录 SHALL 不可见（本地存储不跨设备），应用 SHALL 展示空历史状态
