# ADR-0005 saas_multi_tenancy

Date: 2026-05-20

## Context

ContractFlow 從單一企業內部流程系統升級為 B2B SaaS 平台後，需要支援多個 Organization 同時使用同一套系統。核心風險是跨租戶資料外洩，因此客戶、專案、合約、退費案件、文件、通知與 Audit Log 都需要明確的租戶邊界。

## Decision

MVP 採用 shared database / shared schema，多租戶資料以 `organization_id` 隔離。租戶內授權模型為：

```text
User -> OrganizationMember -> Role -> Permission
```

Tenant-owned API 使用 `/api/orgs/{orgId}/...` 作為租戶 context。Service 與 Repository 必須驗證 membership，且所有 tenant-owned resource 查詢都必須帶 `organization_id` 條件。

## Consequences

優點：

1. SaaS 架構清楚，MVP 不需要為每個客戶拆 schema 或 database。
2. 查詢、索引、Audit Log 都能用 `organization_id` 做一致的資料隔離。
3. 同一使用者可加入多個 Organization，且在不同 Organization 有不同角色。

代價：

1. 每個 tenant-owned 查詢都必須小心帶入 `organization_id`。
2. 需要測試跨租戶存取不可發生。
3. 未來若客戶量或隔離要求提高，可能需要評估 schema-per-tenant 或 database-per-tenant。
