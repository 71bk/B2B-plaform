# ADR-0003 audit_log_and_status_log

Date: 2026-05-20

## Context

系統需要追蹤案件流程，也需要稽核使用者對各種資源的操作。如果只用一張 log 表，會混淆流程歷史與操作稽核。

## Decision

分離兩種紀錄：

1. `refund_case_status_logs`：只記錄退費案件狀態流轉。
2. `operation_audit_logs`：記錄所有重要操作。

## Consequences

優點：

1. 案件流程歷史容易查詢。
2. Audit Log 可跨資源使用。
3. 面試時能清楚說明稽核設計。

代價：

1. 狀態轉換時需同時寫兩種 log。
2. Service transaction 需要更嚴格控管。

