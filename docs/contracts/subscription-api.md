# Subscription API

## POST /v1/subscription/activate

用于客户端在购买完成后激活订阅。

### Headers

- `X-Install-ID`: 必填

### 请求体

```json
{
  "product_id": "wintrain.pro.monthly",
  "original_transaction_id": "1000001234567890",
  "signed_transaction_info": "JWS_PAYLOAD"
}
```

### 响应

```json
{
  "subscription": {
    "status": "active",
    "product_id": "wintrain.pro.monthly",
    "expires_at": "2026-05-01T00:00:00Z"
  },
  "quota": {
    "plan": "pro",
    "remaining_total_successes": null,
    "daily_remaining_successes": null,
    "is_pro": true,
    "snapshot_at": "2026-04-01T08:00:00Z",
    "expires_at": "2026-04-01T08:05:00Z"
  }
}
```

## POST /v1/subscription/restore

恢复购买并绑定到当前设备。

### 请求体

```json
{
  "original_transaction_id": "1000001234567890"
}
```

### 说明

- MVP 主路径允许客户端主动触发恢复
- Apple Server Notifications V2 用于后续状态回写和补偿
