## Context

该 change 对应 `recommended-first-changes.md` 中的 `011-result-display`。当前结果页和历史详情页已经能展示成功分析结果，并对不同状态做基本呈现。

## Goals / Non-Goals

**Goals**
- 固化结果展示行为
- 说明成功结果写入本地历史的边界

**Non-Goals**
- 不在本 change 中重做视觉设计
- 不加入云端历史回放

## Decisions

### D1. 结果页直接消费结构化分析结果

客户端结果页围绕结构化反馈、动作信息和 clip 元数据展示。

### D2. 历史详情复用结果视图

相同的结果展示逻辑在历史详情中复用，避免两套渲染语义分叉。

### D3. 成功结果进入本地历史

对用户有价值的成功分析结果会写入本地历史，用于后续查看。

## Risks / Trade-offs

- 低置信度与失败的详细交互仍可进一步细化

## Open Questions

- 后续是否需要更细颗粒度的片段播放 UI
