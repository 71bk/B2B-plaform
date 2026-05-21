# 文件導覽（docs/）

ContractFlow 文件採用與參考專案相同的編號式佈置：先讀總覽，再讀 API、DB、安全、流程、部署與開發規範。

---

## 讀文件順序（建議）

1. `01_專案架構書.md`
2. `02_技術棧.md`
3. `03_使用者故事.md`
4. `04_API_合約.md`
5. `05_DB_資料庫設計.md`
6. `06_Auth_安全設計.md`
7. `09_退費審核流程.md`
8. `12_後端開發規範.md`
9. `14_後端_Smoke_測試基線.md`

---

## 文件清單

| 文件 | 說明 |
|---|---|
| `01_專案架構書.md` | 專案定位、模組、資料表、流程與開發階段 |
| `02_技術棧.md` | MVP 與第二階段技術棧、測試與安全規範 |
| `03_使用者故事.md` | 角色、Epic、User Story、驗收條件 |
| `04_API_合約.md` | REST API、回應格式、錯誤碼、主要 request/response |
| `05_DB_資料庫設計.md` | schema、table、index、migration 規則 |
| `06_Auth_安全設計.md` | JWT Cookie、Refresh Token、RBAC、CSRF |
| `07_文件上傳流程.md` | 合約與退款文件上傳、下載、權限與儲存策略 |
| `08_AI_RAG_設計.md` | 合約搜尋、案件摘要、缺件提醒的 RAG 設計 |
| `09_退費審核流程.md` | 退費狀態機、操作角色、流程紀錄與通知事件 |
| `10_部署與基礎設施.md` | Docker Compose、環境變數、CI/CD、Nginx |
| `11_可觀測性與日誌.md` | traceId、logging、metrics、audit correlation |
| `12_後端開發規範.md` | 分層、命名、DTO、Exception、Transaction |
| `13_後端程式碼審核.md` | Code review checklist |
| `14_後端_Smoke_測試基線.md` | 後端最小 smoke test 流程 |
| `15_面試用_ContractFlow_技術重點.md` | 面試介紹、技術亮點與可回答問題 |
| `contractflow_v1_ddl.sql` | 初版資料庫 DDL 草案 |

---

## ADR（Architecture Decision Record）

ADR 放在 `docs/adr/`：

| ADR | 決策 |
|---|---|
| `0001_auth_cookie_jwt_refresh_rotation.md` | 使用 JWT Cookie + Refresh Rotation |
| `0002_refund_state_machine.md` | 退費流程使用狀態機控管 |
| `0003_audit_log_and_status_log.md` | Audit Log 與 Status Log 分離 |
| `0004_postgres_jsonb_pgvector.md` | PostgreSQL JSONB 與 pgvector 使用邊界 |
| `0005_saas_multi_tenancy.md` | SaaS 多租戶資料隔離策略 |

---

## 維護規則

1. 架構或流程變更時，先更新對應文件，再開始改程式。
2. API 變更需同步更新 `04_API_合約.md`。
3. DB schema 變更需同步更新 `05_DB_資料庫設計.md` 與 Flyway migration。
4. 重大技術決策需新增 ADR，不直接覆蓋歷史原因。
5. 文件內容以 MVP 為主，第二階段功能需明確標示。
