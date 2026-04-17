# Video Upload API

## POST /v1/analysis

用于上传视频并同步触发分析。

## 请求

### Headers

- `X-Install-ID`: 必填，Keychain UUID
- `Content-Type`: `multipart/form-data`

### Form Fields

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `exercise_id` | string | 是 | `squat` / `lat-pulldown` / `bench-press` / `barbell-row` / `deadlift` |
| `video` | file | 是 | `mp4` / `mov` |
| `client_request_id` | string | 否 | 客户端幂等追踪 |

### 限制

- 最大文件大小：`200 MB`
- 建议上传编码：H.264 / AAC
- 服务端允许的 mime：`video/mp4`, `video/quicktime`

## 响应

响应体定义见 [analysis-api.md](/Users/junthy/Work/WinTrain/docs/contracts/analysis-api.md)。

## 失败场景

- 文件过大：`413 video_too_large`
- 文件格式不支持：`415 unsupported_media_type`
- 配额不足：`402 quota_exhausted`
- 缺少 `install_id`：`400 missing_install_id`
