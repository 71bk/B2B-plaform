# 面試用 ContractFlow 技術重點

---

## 一句話介紹

ContractFlow 是一套給中小企業使用的 B2B 合約與退費審核 SaaS 平台，使用 Spring Boot、PostgreSQL、Spring Security、JWT Cookie、Organization 多租戶隔離、RBAC、狀態機與 Audit Log，解決退費流程不透明、權限不清楚、操作不可追蹤與多客戶資料隔離的問題。

---

## 履歷描述

中文：

> 使用 Spring Boot、PostgreSQL、Redis 與 Docker 開發 B2B 合約與退費審核 SaaS 平台，實作 JWT 身分驗證、多租戶 Organization 資料隔離、RBAC 權限控管、退費狀態機、Audit Log、文件上傳、Dashboard 統計與 AI 合約搜尋功能。

英文：

> Developed a B2B contract and refund approval SaaS platform using Spring Boot, PostgreSQL, Redis, and Docker. Implemented JWT authentication, multi-tenant organization isolation, RBAC, approval workflows, audit logs, file management, dashboard analytics, and AI-powered contract search with RAG.

---

## 技術亮點

1. 不是單純 CRUD，而是具備狀態流程與多租戶隔離的 SaaS 系統。
2. 使用 Organization + RBAC 控制不同企業與不同角色的操作範圍。
3. 使用狀態機避免非法審核流程。
4. 使用 Audit Log 保存重要操作紀錄。
5. 使用 Status Log 追蹤每次案件狀態變更。
6. 使用 optimistic locking 避免多人同時審核覆蓋狀態。
7. 使用 Flyway 管理資料庫版本。
8. 使用 Spring Security Test 測試角色權限。
9. 使用 `organization_id` 與 scoped query 避免跨租戶資料外洩。
10. 第二階段可加入 Redis、Docker、Testcontainers、AI / RAG。

### 多租戶怎麼設計？

MVP 採 shared database / shared schema。每個 tenant-owned resource 都帶 `organization_id`，API 使用 `/api/orgs/{orgId}/...` 表示租戶 context。授權模型是 `User -> OrganizationMember -> Role -> Permission`，同一使用者可加入多個 Organization 並擁有不同角色。

---

## 可回答的面試問題

### 為什麼要用狀態機？

退費案件不能任意跳關，例如 Sales 不應直接核准案件，Admin 也不能直接把案件標記為已退款。狀態機把合法轉換集中定義，讓流程可讀、可測，也避免 Controller 或 Service 各自修改狀態造成規則分散。

### Audit Log 和 Status Log 差在哪？

Status Log 專門記錄退費案件的狀態流轉，例如 `ADMIN_REVIEW -> FINANCE_REVIEW`。Audit Log 記錄所有重要操作，例如建立案件、修改金額、上傳文件、角色變更。兩者目的不同，因此分開設計。

### 如何避免同一案件被兩個人同時審核？

在 `refund_cases` 加上 `version` 欄位，使用 JPA optimistic locking。當兩個 request 同時讀取同一版本時，先提交者成功，後提交者因版本不一致回傳 409，避免覆蓋狀態。

### 為什麼 JWT 放 HttpOnly Cookie？

HttpOnly Cookie 可以降低 token 被 XSS 直接讀取的風險。因為 Cookie 會自動附帶，所以需要搭配 SameSite 或 CSRF Token 來處理 CSRF 風險。

### 為什麼 MVP 不先做 AI？

這個專案的核心價值是企業流程管理。若先做 AI，容易分散焦點。先完成登入、RBAC、退費狀態機與 Audit Log，才是後端工程能力的主體；AI / RAG 放第二階段作為加分功能。
