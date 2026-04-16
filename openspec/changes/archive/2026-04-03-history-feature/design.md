## Context

该 change 对应 `recommended-first-changes.md` 中的 `013-history-feature`。历史数据本地保存、历史列表和详情页已在 iOS 端实现。

## Goals / Non-Goals

**Goals**
- 固化 MVP v1 本地历史能力
- 明确历史功能不依赖后端云同步

**Non-Goals**
- 不实现跨设备历史同步
- 不引入后端历史查询 API

## Decisions

### D1. 历史记录仅本地存储

用户可见历史由本地存储驱动，服务端不提供用户历史读取接口。

### D2. 历史详情复用结果展示

历史详情沿用分析结果展示语义，避免独立维护第二套显示逻辑。

### D3. 历史列表支持动作筛选

用户可以按动作类型筛选已有历史记录，以提高可读性。

## Risks / Trade-offs

- 换设备会丢失历史数据
- 后续若引入云同步，需要单独 change 处理

## Open Questions

- 免费与订阅用户的历史可见范围是否需要进一步收紧
