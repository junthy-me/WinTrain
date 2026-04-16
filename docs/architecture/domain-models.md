# WinTrain 领域模型

## Device

```text
Device
- install_id: string
- original_transaction_id: string?
- created_at: datetime
- updated_at: datetime
- last_seen_at: datetime
- quota_state: QuotaState
- subscription_state: SubscriptionState
```

## QuotaState

```text
QuotaState
- free_total_limit: int
- free_total_used: int
- daily_success_limit: int
- daily_success_used: int
- daily_window_start: date
```

## AnalysisSession

```text
AnalysisSession
- session_id: string
- install_id: string
- exercise_id: string
- request_status: queued | processing | completed
- analysis_status: success | low_confidence | failed
- created_at: datetime
- completed_at: datetime?
- request_trace_id: string
- provider_name: string?
- provider_latency_ms: int?
- failure_code: string?
```

## AnalysisResult

```text
AnalysisResult
- session_id: string
- status: success | low_confidence | failed
- exercise_id: squat | lat-pulldown
- overall_summary: string
- memory_cue: string?
- low_confidence_reason: string?
- feedbacks: Feedback[]
- quota_snapshot: QuotaSnapshot
```

## Feedback

```text
Feedback
- rank: int
- title: string
- description: string
- how_to_fix: string
- cue: string
- severity: major | minor | info
- clip: Clip?
```

## Clip

```text
Clip
- start_ms: int
- end_ms: int
```

## Subscription

```text
Subscription
- original_transaction_id: string
- install_id: string
- product_id: string
- status: inactive | active | grace_period | expired | revoked
- expires_at: datetime?
- latest_transaction_id: string?
- source: storekit_client | apple_server_notification | app_store_server_api
```

## HistoryRecord

```text
HistoryRecord
- local_id: string
- session_id: string
- exercise_id: string
- created_at: datetime
- status: success
- overall_summary: string
- memory_cue: string?
- primary_feedback_title: string
- local_clip_path: string?
```

## 非模型字段

MVP v1 不把以下字段纳入核心领域模型：

- 重量
- 次数
- 原始视频持久化路径
- 云端历史同步状态
