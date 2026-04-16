# WinTrain 数据流

## 1. 成功路径

```text
iOS 录制视频
  -> POST /v1/analysis
  -> 后端校验 install_id / quota / 文件大小 / 动作类型
  -> 后端写入临时文件
  -> 抽取关键帧
  -> 调用 Vision LLM
  -> 解析结构化 JSON
  -> 标准化 AnalysisResult
  -> 原子扣减 quota
  -> 返回结果 + 最新 quota snapshot
  -> iOS 裁剪本地代表性片段
  -> iOS 持久化本地历史
```

## 2. low_confidence 路径

```text
视频上传
  -> LLM 或标准化层认定置信度不足
  -> status=low_confidence
  -> 不扣减 quota
  -> iOS 展示重拍引导
  -> 不写入历史
```

## 3. failed 路径

```text
视频上传
  -> 文件校验失败 / LLM 超时 / 网络错误 / 解析失败
  -> status=failed
  -> 不扣减 quota
  -> iOS 展示错误提示与重试
  -> 不写入历史
```

## 4. 配额流

- App 启动：`GET /v1/quota`
- 分析返回：`POST /v1/analysis` 响应附带最新 quota snapshot
- 本地快照有效期：`5 分钟`
- 客户端仅展示，服务端最终裁决

## 5. 标识流

- 首次启动时从 Keychain 读取 `install_id`
- 若不存在则生成 UUID 并保存
- 每次请求在 `X-Install-ID` Header 中携带
- 服务端用 `install_id` 作为免费配额主键

## 6. 订阅流

- 客户端购买后拿到 StoreKit 交易信息
- 客户端把 `signedTransactionInfo` / `originalTransactionId` 发送到后端
- 后端查询 Apple App Store Server API，刷新订阅状态
- 后续 Apple Server Notifications V2 用于续费、退款、撤销同步

## 7. 本地历史流

- 仅 `success` 写入历史
- 存储内容：结构化结果、摘要字段、本地派生片段路径
- 不保存完整原始视频
- 换设备后历史不迁移
