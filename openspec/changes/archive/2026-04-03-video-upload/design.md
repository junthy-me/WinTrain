## Context

该 change 对应 `recommended-first-changes.md` 中的 `008-video-upload`。当前实现已经覆盖 iOS 侧上传入口壳和后端接收链路。

## Goals / Non-Goals

**Goals**
- 固化 MVP 视频上传行为
- 明确客户端与服务端各自承担的职责

**Non-Goals**
- 不在本 change 中优化视频压缩策略
- 不切换对象存储直传

## Decisions

### D1. 客户端负责采集与发起上传

iOS 负责视频录制、选择和上传进度管理。

### D2. 后端负责接收与校验

后端接收视频数据，对大小和格式做基础校验，然后进入后续分析编排。

### D3. 上传链路保持直传后端

当前仍采用客户端直传后端，不引入对象存储预签名上传。

## Risks / Trade-offs

- 大视频上传体验和压缩策略后续仍可继续优化

## Open Questions

- 是否在后续引入客户端压缩与断点重传
