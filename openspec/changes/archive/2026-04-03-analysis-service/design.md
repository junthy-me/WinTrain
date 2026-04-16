## Context

该 change 对应 `recommended-first-changes.md` 中的 `009-analysis-service`。LLM Spike 已完成主路径验证，后端分析链路也已落地到正式工程。

## Goals / Non-Goals

**Goals**
- 固化关键帧抽取与分析编排的 MVP 设计
- 明确 provider 抽象与结构化输出处理边界

**Non-Goals**
- 不重新评估 LLM 路线
- 不在本 change 中补做 Gemini 对照

## Decisions

### D1. 正式工程复用 Spike 的主路径结论

后端采用关键帧抽取后调用 Vision-capable provider 的路线，provider 层保持抽象。

### D2. 分析链路显式处理低置信度与失败

分析服务不只返回成功结果，还需要能表达低置信度和技术失败，以支撑 UI 与配额逻辑。

### D3. 提供 mock 与真实 provider 壳

正式工程中保留 mock provider 以便本地开发，也提供 OpenAI-compatible provider 壳。

## Risks / Trade-offs

- 生产 provider、提示词和帧策略仍可随着后续优化继续调整

## Open Questions

- 更细的 provider 选择策略与成本优化
