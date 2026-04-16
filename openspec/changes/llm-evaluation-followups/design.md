## Context

当前 `llm-spike` 已经回答了“是否足以支持当前 MVP API 设计推进”这个问题，但还没有完成更全面的模型对照与优化验证。

## Goals / Non-Goals

**Goals**
- 单独追踪 Gemini 对照实验
- 单独追踪后续延迟、schema 稳定性、时间戳精度优化验证

**Non-Goals**
- 不重做已经完成的主路径 Spike
- 不阻塞当前 MVP 主流程

## Decisions

### D1. 主路径 Spike 与后续优化分离

原始 Spike 只负责回答主路径是否足以支撑 MVP 继续推进；更深的 provider 对照和优化工作单独拆出。

### D2. Gemini 对照保持可选但有明确归属

Gemini 不再挂在 `llm-spike` 里作为未完成尾项，而是作为 follow-up change 中的明确任务。

## Risks / Trade-offs

- 后续优化结果可能反过来影响分析服务的 provider 选择或预处理策略

## Open Questions

- Gemini 对照是否会显著改变当前路线选择
- 后续是否需要引入关键帧/rep 分割预处理
