# Quota API

## GET /v1/quota

获取最新配额快照。

### Headers

- `X-Install-ID`: 必填

### 响应

```json
{
  "plan": "free",
  "remaining_total_successes": 2,
  "daily_remaining_successes": 1,
  "is_pro": false,
  "snapshot_at": "2026-04-01T08:00:00Z",
  "expires_at": "2026-04-01T08:05:00Z"
}
```

### 说明

- `expires_at` 仅表示客户端缓存建议失效时间
- 最终裁决仍以服务端为准
