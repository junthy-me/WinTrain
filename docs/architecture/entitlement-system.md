# WinTrain 权益系统设计

## 1. 目标

统一设计设备身份、免费配额、订阅状态和裁决流程。

## 2. 标识

- `install_id`: Keychain UUID，配额主键
- `original_transaction_id`: Apple 原始交易锚点，用于恢复购买

## 3. 免费规则

- 总成功分析次数：`3`
- 每日成功分析上限：`1`
- 仅 `status=success` 扣减
- `low_confidence` / `failed` 不扣减

## 4. 权益状态

### Free

- 受每日和累计次数限制

### Pro

- 无每日限制
- 无累计限制
- 仍受服务端文件大小和超时规则约束

## 5. 裁决原则

- 服务端是唯一权威
- 客户端只缓存快照
- 所有扣减必须在结构化校验通过后原子完成

## 6. 快照结构

```json
{
  "plan": "free",
  "remaining_total_successes": 1,
  "daily_remaining_successes": 0,
  "is_pro": false,
  "snapshot_at": "2026-04-01T08:00:00Z",
  "expires_at": "2026-04-01T08:05:00Z"
}
```

## 7. 状态回退

### 退款/撤销

- Apple 通知到达后服务端更新订阅状态为 `revoked`
- 后续 quota 裁决按 Free 规则执行

### 订阅过期

- 过期后回退到 Free
- 已存在历史记录不删除

## 8. 恢复购买

- 客户端发起 StoreKit 恢复
- 获取 `originalTransactionId`
- 提交给后端
- 后端拉取 Apple 状态并绑定到当前 `install_id`

## 9. MVP 简化原则

- 不做账户系统
- 不做跨平台共享权益
- 不做营销优惠券
- 不做团队订阅
