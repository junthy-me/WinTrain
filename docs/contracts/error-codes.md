# Error Codes

## 统一结构

```json
{
  "error": {
    "code": "video_too_large",
    "message": "Uploaded file exceeds the 200 MB limit.",
    "retryable": false
  }
}
```

## 错误码

| HTTP | code | 说明 | retryable |
|------|------|------|-----------|
| 400 | `missing_install_id` | 缺少安装标识 | false |
| 400 | `invalid_exercise_id` | 动作类型不支持 | false |
| 400 | `invalid_request` | 请求体非法 | false |
| 402 | `quota_exhausted` | 免费次数已用尽 | false |
| 402 | `subscription_required` | 当前功能需要订阅 | false |
| 408 | `analysis_timeout` | 分析超时 | true |
| 413 | `video_too_large` | 视频过大 | false |
| 415 | `unsupported_media_type` | 格式不支持 | false |
| 422 | `analysis_low_confidence` | 低置信度，不扣次 | true |
| 502 | `provider_unavailable` | 上游模型不可用 | true |
| 500 | `internal_error` | 服务端内部错误 | true |
