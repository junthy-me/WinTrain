# Analysis API

## Analysis Response

```json
{
  "session_id": "as_123",
  "video_source": "direct_upload",
  "status": "success",
  "exercise_id": "squat",
  "overall_summary": "整体动作基本稳定，但最低点脚跟离地。",
  "memory_cue": "脚跟踩实地面，屁股向后坐。",
  "feedbacks": [
    {
      "rank": 1,
      "title": "脚跟离地",
      "description": "最低点脚跟离地，稳定性不足。",
      "how_to_fix": "保持足底三点受力，重心后移。",
      "cue": "脚跟踩死地面。",
      "severity": "major",
      "clip": {
        "start_ms": 1800,
        "end_ms": 3600
      }
    }
  ],
  "low_confidence_reason": null,
  "quota": {
    "plan": "free",
    "remaining_total_successes": 2,
    "daily_remaining_successes": 0,
    "is_pro": false,
    "snapshot_at": "2026-04-01T08:00:00Z",
    "expires_at": "2026-04-01T08:05:00Z"
  }
}
```

### success with no issues found

```json
{
  "session_id": "as_124",
  "video_source": "direct_upload",
  "status": "success",
  "exercise_id": "squat",
  "overall_summary": "整体动作稳定，未发现需要重点纠正的问题。",
  "memory_cue": "保持节奏和稳定性，继续保持。",
  "feedbacks": [],
  "low_confidence_reason": null,
  "quota": {
    "plan": "free",
    "remaining_total_successes": 1,
    "daily_remaining_successes": 0,
    "is_pro": false,
    "snapshot_at": "2026-04-01T08:00:00Z",
    "expires_at": "2026-04-01T08:05:00Z"
  }
}
```

## 字段定义

| 字段 | 类型 | 说明 |
|------|------|------|
| `session_id` | string | 分析会话 ID |
| `video_source` | string | 固定为 `direct_upload`，为未来对象存储预留 |
| `status` | string | `success` / `low_confidence` / `failed` |
| `exercise_id` | string | `squat` / `lat-pulldown` / `bench-press` / `barbell-row` / `deadlift` |
| `overall_summary` | string | 整体结论 |
| `memory_cue` | string/null | 可选。一句记忆口令 |
| `feedbacks` | array | 反馈项数组；`status=success` 时可为空，表示未发现需要重点纠正的问题 |
| `low_confidence_reason` | string/null | 仅 `low_confidence` 时填写 |
| `quota` | object | 最新配额快照 |

## feedbacks[]

| 字段 | 类型 | 说明 |
|------|------|------|
| `rank` | int | 从 `1` 开始排序 |
| `title` | string | 问题标题 |
| `description` | string | 问题描述 |
| `how_to_fix` | string | 改法 |
| `cue` | string | 简短提醒 |
| `severity` | string | `major` / `minor` / `info` |
| `clip` | object/null | 代表性错误片段 |

## 三态语义

### success

- 分析完成
- 结构化校验通过
- 扣减配额
- iOS 写入历史
- `feedbacks` 可以为空；为空时表示“未发现明显问题”

### low_confidence

- 画面不适合可靠判断，或 provider 输出可解析但不足以安全交付
- 不扣减配额
- iOS 不写入历史

### failed

- 上传/抽帧/provider 调用发生技术失败
- 不扣减配额
- iOS 不写入历史
