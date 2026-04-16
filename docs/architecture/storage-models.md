# WinTrain 存储模型

## 1. 后端存储选型

- 主数据库：PostgreSQL
- 本地开发：可使用 Docker 启动 PostgreSQL
- 临时缓存：MVP v1 不单独引入 Redis

原因：

- 需要事务支持配额原子扣减
- 需要维护设备、订阅、操作日志
- 比 SQLite 更适合后续扩展

## 2. 后端表设计

### devices

| 字段 | 类型 | 说明 |
|------|------|------|
| install_id | text pk | 设备标识 |
| original_transaction_id | text null | 恢复购买锚点 |
| created_at | timestamptz | 创建时间 |
| updated_at | timestamptz | 更新时间 |
| last_seen_at | timestamptz | 最近访问 |

### quotas

| 字段 | 类型 | 说明 |
|------|------|------|
| install_id | text pk | 关联设备 |
| free_total_limit | integer | 固定 3 |
| free_total_used | integer | 已用成功次数 |
| daily_success_limit | integer | 固定 1 |
| daily_success_used | integer | 当日已用 |
| daily_window_start | date | 当日窗口 |
| updated_at | timestamptz | 更新时间 |

### subscriptions

| 字段 | 类型 | 说明 |
|------|------|------|
| original_transaction_id | text pk | Apple 原始交易 |
| install_id | text | 当前绑定设备 |
| product_id | text | 订阅产品 |
| status | text | inactive/active/grace_period/expired/revoked |
| expires_at | timestamptz null | 到期时间 |
| latest_transaction_id | text null | 最新交易 |
| updated_at | timestamptz | 更新时间 |

### analysis_logs

| 字段 | 类型 | 说明 |
|------|------|------|
| session_id | text pk | 分析会话 |
| install_id | text | 设备 |
| exercise_id | text | 动作 |
| analysis_status | text | success/low_confidence/failed |
| provider_name | text null | provider |
| provider_latency_ms | integer null | provider 时延 |
| failure_code | text null | 失败码 |
| created_at | timestamptz | 创建时间 |
| completed_at | timestamptz null | 完成时间 |

## 3. iOS 本地存储

- 历史记录：SwiftData（底层 SQLite）
- 配额快照：`UserDefaults`
- `install_id`：Keychain
- 派生片段：App Sandbox 文件目录

### 历史记录字段

| 字段 | 类型 | 说明 |
|------|------|------|
| local_id | UUID | 本地主键 |
| session_id | String | 后端会话 |
| exercise_id | String | 动作 |
| created_at | Date | 创建时间 |
| overall_summary | String | 摘要 |
| memory_cue | String? | 可选记忆口令 |
| primary_feedback_title | String | 主问题 |
| local_clip_path | String? | 本地片段路径 |

## 4. 生命周期与清理

- 原始视频：分析完成且派生片段生成后删除
- 派生片段：由用户历史记录持有；用户删除历史时一并清理
- 后端临时视频和关键帧：请求完成即清理
