# WinTrain 订阅流程

## 1. 购买流程

```text
用户点击订阅
  -> StoreKit 2 发起购买
  -> 客户端获取已验证交易
  -> 客户端调用 POST /v1/subscription/activate
  -> 后端校验 signed transaction / original transaction id
  -> 后端写入 Subscription 状态
  -> 返回最新 entitlement snapshot
```

## 2. 恢复购买流程

```text
用户点击恢复购买
  -> StoreKit 2 sync
  -> 客户端枚举当前有效交易
  -> 取 originalTransactionId
  -> POST /v1/subscription/restore
  -> 后端调用 App Store Server API
  -> 绑定到当前 install_id
  -> 返回 entitlement snapshot
```

## 3. 订阅状态机

```text
inactive
  -> active
  -> grace_period
  -> expired
  -> revoked
```

### inactive

- 无有效订阅

### active

- 权益生效

### grace_period

- 续费扣款失败但仍在宽限期
- 权益继续可用

### expired

- 订阅结束
- 权益回退为 Free

### revoked

- Apple 撤销或退款
- 权益立即失效

## 4. 事件来源

- 客户端主动激活/恢复
- Apple Server Notifications V2
- 后端定时补偿校验

## 5. MVP 取舍

- 主路径优先依赖客户端触发激活/恢复
- Apple Server Notifications V2 作为后续一致性补偿
- 若通知配置未就绪，客户端恢复购买仍可工作，但退款/撤销回写会滞后
