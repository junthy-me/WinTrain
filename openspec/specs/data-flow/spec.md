# Spec: data-flow

## Purpose

定义 WinTrain MVP 的核心数据流，包括分析链路、配额状态同步和设备标识生命周期。

## Requirements

### Requirement: 核心分析数据流
系统 SHALL 支持以下完整数据流：iOS 录制视频 → 上传至后端 → 后端抽取关键帧 → 调用 LLM → 解析结构化结果 → 返回 iOS → iOS 展示结果并保存本地历史。

MVP v1 的分析链路 SHALL 采用同步请求-响应模式：iOS 客户端发出请求后阻塞等待，后端在同一次 HTTP 连接中完成分析并返回结果。MVP v1 SHALL NOT 引入异步任务队列、轮询机制或回调通知。

配额扣减 SHALL 仅在以下条件同时满足时原子执行：分析结果 status 为 `success`，且后端对 LLM 输出完成结构化校验通过。status 为 `low_confidence` 或 `failed` 时 SHALL NOT 扣减配额。

#### Scenario: 分析成功完整流程
- **WHEN** 用户完成视频录制并提交分析
- **THEN** 系统 SHALL 按以下顺序在同一次同步 HTTP 请求中处理：
  1. iOS 客户端上传视频至 `POST /v1/analysis`，保持连接等待响应
  2. 后端接收视频，抽取关键帧
  3. 后端调用 LLM Vision API，传入关键帧序列
  4. 后端解析 LLM 输出为结构化 JSON 并通过结构化校验
  5. 后端原子扣减配额，返回 `status: success` 的分析结果（含片段时间戳）给 iOS
  6. iOS 展示结果页，同时根据返回的片段时间戳立即从原始视频裁剪并保存代表性片段短视频至本地
  7. iOS 将结构化分析结果、必要展示字段、本地派生片段引用写入本地 Core Data；原始视频在派生片段生成成功后可删除

#### Scenario: 分析成功但未发现明显问题
- **WHEN** 后端返回 `status: success` 且 `feedbacks` 为空数组
- **THEN** iOS SHALL 展示优秀/继续保持结果页，SHALL 将本次结果写入本地历史，且 SHALL NOT 强制导出代表性问题片段

#### Scenario: 分析结果为 low_confidence
- **WHEN** LLM 判断视频画面质量不足，或后端结构化校验未通过
- **THEN** 后端 SHALL 返回 `status: low_confidence` 的响应，SHALL NOT 扣减配额；iOS SHALL 展示重拍引导页，SHALL NOT 将本次结果写入历史记录

#### Scenario: 分析结果为 failed
- **WHEN** 后端发生超时、LLM 调用失败等技术错误
- **THEN** 后端 SHALL 返回 `status: failed` 的响应，SHALL NOT 扣减配额；iOS SHALL 展示错误提示和重试选项，SHALL NOT 将本次结果写入历史记录

---

### Requirement: 配额状态数据流
配额状态 SHALL 由服务端维护，iOS 客户端通过以下两种方式获取：App 启动时主动查询 `GET /v1/quota`；每次分析响应中附带最新配额状态。客户端 SHALL 缓存配额快照，有效期 5 分钟。

客户端缓存的配额快照 SHALL 仅用于 UI 展示与弱提示（如首页剩余次数展示、提前告知次数不足），SHALL NOT 用于最终裁决。最终配额裁决始终以服务端为准。

#### Scenario: App 启动时刷新配额
- **WHEN** iOS 应用启动
- **THEN** 客户端 SHALL 请求 `GET /v1/quota` 获取最新配额状态，并更新本地缓存

#### Scenario: 分析完成后配额更新
- **WHEN** 分析请求返回（无论成功或失败）
- **THEN** 响应体 SHALL 包含最新配额状态，iOS 客户端 SHALL 用此数据刷新本地缓存，无需额外请求

#### Scenario: 配额缓存过期
- **WHEN** 本地配额缓存已超过 5 分钟
- **THEN** 客户端 SHALL 在下次进入首页时静默刷新配额，展示期间使用过期缓存数据并标注"可能未更新"

---

### Requirement: 设备标识数据流
iOS 客户端 SHALL 在首次启动时优先尝试从 Keychain 读取已有 `install_id`；若不存在，则生成新 UUID 并写入 Keychain。此后每次请求 SHALL 在 Header 中携带该 `install_id`。后端 SHALL 以 `install_id` 作为配额计数的主键。

Keychain 标识的持久性依赖设备和 iCloud Keychain 配置，不保证在所有场景下可恢复。若标识不可恢复，客户端 SHALL 生成新 `install_id`，MVP v1 接受此边界行为（免费次数从头计算）。

#### Scenario: 首次安装生成设备标识
- **WHEN** 用户首次安装并启动应用，Keychain 中不存在 `install_id`
- **THEN** iOS 客户端 SHALL 生成 UUID，写入 Keychain，并在后续所有 API 请求的 Header 中携带

#### Scenario: 标识可恢复时复用
- **WHEN** 用户卸载后重新安装，Keychain 中仍存在原有 `install_id`（如 iCloud Keychain 同步保留）
- **THEN** iOS 客户端 SHALL 直接读取并复用该 `install_id`，配额记录不重置

#### Scenario: 标识不可恢复时生成新标识
- **WHEN** 用户卸载后重新安装，Keychain 中原有 `install_id` 不可读取
- **THEN** iOS 客户端 SHALL 生成新 UUID 作为 `install_id`，免费次数从头计算；此为 MVP v1 可接受的边界行为
