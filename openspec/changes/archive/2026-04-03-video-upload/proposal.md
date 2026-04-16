## Why

视频上传链路已经在 iOS 和后端两侧打通骨架，但没有对应的 OpenSpec change 记录实际范围和行为边界。需要补齐流程，明确当前 MVP 上传能力的状态。

## What Changes

- 为视频录制、选择、上传能力补齐 OpenSpec 工件
- 记录 iOS 上传入口、上传服务和后端接收路径
- 明确文件校验、超时与进度展示的行为边界

## Capabilities

### New Capabilities
- `video-upload`: WinTrain MVP 的视频采集与上传链路

### Modified Capabilities

（无）

## Impact

- iOS：视频选择/录制入口
- iOS：上传服务
- 后端：视频接收接口
- 文档：`docs/contracts/video-upload-api.md`
