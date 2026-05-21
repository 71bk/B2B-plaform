# ADR-0002 refund_state_machine

Date: 2026-05-20

## Context

退費案件需要跨 Sales、Admin、Finance、Manager 多角色審核。若任意 API 都可以直接修改狀態，容易產生跳關、越權或流程不可追蹤。

## Decision

退費流程使用狀態機控管。MVP 狀態為：

```text
DRAFT
ADMIN_REVIEW
FINANCE_REVIEW
MANAGER_REVIEW
APPROVED
REJECTED
PAID
CANCELLED
```

MVP 不保留 `SUBMITTED`，Sales submit 後直接進入 `ADMIN_REVIEW`。

## Consequences

優點：

1. 狀態轉換規則集中。
2. 測試案例清楚。
3. 可以防止非法跳關。

代價：

1. 每次新增流程節點都需要同步調整狀態機、API、測試與文件。

