## Context

该 change 对应 `recommended-first-changes.md` 中的 `005-entitlement-and-subscription-design`。当前实现已经具备：
- `install_id` 设备标识
- 免费三次且每日最多一次成功分析的规则
- 后端配额最终裁决
- StoreKit 2 客户端壳与订阅激活/恢复接口壳

## Goals / Non-Goals

**Goals**
- 回填权益设计为 OpenSpec artifacts
- 明确设备身份、订阅恢复锚点和免费规则
- 记录本地 StoreKit 测试与真实 Apple 集成的现状

**Non-Goals**
- 不在本 change 内完成真实 Apple 资源联调
- 不重新设计配额规则

## Decisions

### D1. 设备身份以 Keychain `install_id` 为主

客户端使用 Keychain 持久化 `install_id`。这是免费额度、分析请求和本地状态的基础标识。

### D2. 订阅恢复以 `originalTransactionId` 为锚点

客户端购买或恢复成功后，将交易信息上送后端；后端使用 `originalTransactionId` 作为订阅恢复关联键。

### D3. 免费配额规则为“累计三次成功分析，每日最多一次”

只有 `success` 扣减额度，`low_confidence` 与 `failed` 不扣减。

### D4. 客户端只展示快照，服务端执行最终裁决

客户端缓存 5 分钟配额快照，用于 UI 提示；分析请求是否允许执行，始终由后端判断。

### D5. 真实 Apple 生产接入单独跟踪

本地 StoreKit 入口和自动化测试骨架已经存在；真实 receipt / server notifications 校验与 CLI 自动化稳定性问题转移到 `apple-subscription-production-readiness`。

## Risks / Trade-offs

- 当前 change 描述的是 MVP 权益设计边界；生产 Apple 接入完成度由 follow-up change 单独跟踪

## Open Questions

- 多设备恢复场景下的边界处理
