# API 合約

> ContractFlow REST API Contract

---

## 命名規範

| 項目 | 規範 |
|---|---|
| Base path | `/api` |
| Resource path | 使用複數名詞，例如 `/orgs/{orgId}/refund-cases` |
| Action endpoint | 使用動詞子路徑，例如 `/orgs/{orgId}/refund-cases/{id}/submit` |
| Request / Response | 使用 JSON |
| 日期時間 | ISO-8601，例如 `2026-05-20T10:30:00` |
| 金額 | JSON number，後端以 `BigDecimal` 處理 |

---

## 通用規範

所有受保護 API 預設需要登入，除非明確標示 public。

Tenant-owned resource API 採用 `/api/orgs/{orgId}/...` 作為租戶 context。後端必須驗證目前使用者是該 Organization 的有效成員，且所有查詢都要帶入 `organization_id`。

寫入型 API：

1. 需要有效 Access Token Cookie。
2. 若跨站部署，需帶 CSRF Header。
3. 需通過角色與資源權限檢查。
4. 重要操作需寫入 Audit Log。

---

## 回傳格式

### ApiResponse

```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "Request processed successfully",
  "data": {},
  "path": "/api/orgs/1/refund-cases",
  "traceId": "abc-123"
}
```

### ErrorResponse

```json
{
  "success": false,
  "code": "REFUND_CASE_INVALID_TRANSITION",
  "message": "Cannot approve refund case from current status",
  "data": null,
  "path": "/api/orgs/1/refund-cases/1/admin-approve",
  "traceId": "abc-123"
}
```

### PageResponse

```json
{
  "content": [],
  "page": 0,
  "size": 20,
  "totalElements": 100,
  "totalPages": 5
}
```

---

## 錯誤碼與 HTTP 狀態

| HTTP | code | 說明 |
|---:|---|---|
| 400 | VALIDATION_ERROR | Request 欄位驗證失敗 |
| 401 | UNAUTHORIZED | 未登入或 Token 無效 |
| 403 | FORBIDDEN | 權限不足 |
| 404 | RESOURCE_NOT_FOUND | 資源不存在 |
| 409 | VERSION_CONFLICT | optimistic locking 版本衝突 |
| 409 | REFUND_CASE_INVALID_TRANSITION | 案件狀態不可轉換 |
| 429 | RATE_LIMITED | 操作過於頻繁 |
| 500 | INTERNAL_SERVER_ERROR | 未預期錯誤 |

---

## Auth

### Endpoints

| Method | Path | 說明 |
|---|---|---|
| POST | `/api/auth/login` | 登入 |
| POST | `/api/auth/logout` | 登出 |
| POST | `/api/auth/refresh` | 更新 Access Token |
| GET | `/api/auth/me` | 取得目前登入者 |
| GET | `/api/auth/csrf` | 取得 CSRF token，跨站部署時使用 |

### Login Request

```json
{
  "email": "sales@example.com",
  "password": "password"
}
```

### Me Response

```json
{
  "id": 1,
  "email": "sales@example.com",
  "name": "Sales User",
  "organizations": [
    {
      "id": 1,
      "name": "Acme Co.",
      "slug": "acme",
      "roles": ["SALES"]
    }
  ]
}
```

---

## Organizations

| Method | Path | Role | 說明 |
|---|---|---|---|
| GET | `/api/orgs` | AUTHENTICATED | 查詢目前使用者可存取的組織 |
| POST | `/api/orgs` | AUTHENTICATED | 建立組織，建立者成為 Owner |
| GET | `/api/orgs/{orgId}` | MEMBER | 組織詳情 |
| PATCH | `/api/orgs/{orgId}` | OWNER / SYSTEM_ADMIN | 更新組織資料 |
| GET | `/api/orgs/{orgId}/members` | OWNER / SYSTEM_ADMIN | 成員列表 |
| POST | `/api/orgs/{orgId}/invitations` | OWNER / SYSTEM_ADMIN | 邀請成員 |
| PATCH | `/api/orgs/{orgId}/members/{memberId}/role` | OWNER / SYSTEM_ADMIN | 更新組織內角色 |
| PATCH | `/api/orgs/{orgId}/members/{memberId}/status` | OWNER / SYSTEM_ADMIN | 啟用或停用組織成員 |

---

## Users / Platform Admin

| Method | Path | Role | 說明 |
|---|---|---|---|
| GET | `/api/admin/users` | SYSTEM_ADMIN | 平台使用者列表 |
| GET | `/api/admin/users/{id}` | SYSTEM_ADMIN | 平台使用者詳情 |
| PATCH | `/api/admin/users/{id}/status` | SYSTEM_ADMIN | 啟用或停用帳號 |

---

## Clients

| Method | Path | Role | 說明 |
|---|---|---|---|
| GET | `/api/orgs/{orgId}/clients` | MEMBER | 查詢客戶 |
| POST | `/api/orgs/{orgId}/clients` | SALES / ADMIN / OWNER / SYSTEM_ADMIN | 建立客戶 |
| GET | `/api/orgs/{orgId}/clients/{id}` | MEMBER | 客戶詳情 |
| PATCH | `/api/orgs/{orgId}/clients/{id}` | ADMIN / OWNER / SYSTEM_ADMIN | 更新客戶 |
| DELETE | `/api/orgs/{orgId}/clients/{id}` | OWNER / SYSTEM_ADMIN | 刪除或停用客戶 |

### Create Client Request

```json
{
  "companyName": "Acme Co.",
  "taxId": "12345678",
  "contactName": "王小明",
  "contactEmail": "contact@acme.test",
  "contactPhone": "02-1234-5678"
}
```

---

## Projects / Contracts

| Method | Path | Role | 說明 |
|---|---|---|---|
| GET | `/api/orgs/{orgId}/projects` | MEMBER | 查詢專案 |
| POST | `/api/orgs/{orgId}/projects` | SALES / ADMIN / OWNER / SYSTEM_ADMIN | 建立專案 |
| GET | `/api/orgs/{orgId}/projects/{id}` | MEMBER | 專案詳情 |
| PATCH | `/api/orgs/{orgId}/projects/{id}` | ADMIN / OWNER / SYSTEM_ADMIN | 更新專案 |
| GET | `/api/orgs/{orgId}/contracts` | MEMBER | 查詢合約 |
| POST | `/api/orgs/{orgId}/contracts` | SALES / ADMIN / OWNER / SYSTEM_ADMIN | 建立合約 |
| GET | `/api/orgs/{orgId}/contracts/{id}` | MEMBER | 合約詳情 |
| PATCH | `/api/orgs/{orgId}/contracts/{id}` | ADMIN / OWNER / SYSTEM_ADMIN | 更新合約 |
| POST | `/api/orgs/{orgId}/contracts/{id}/files` | SALES / ADMIN / OWNER / SYSTEM_ADMIN | 上傳合約文件 |

---

## Refund Cases

| Method | Path | Role | 說明 |
|---|---|---|---|
| GET | `/api/orgs/{orgId}/refund-cases` | MEMBER | 查詢案件，依角色過濾 |
| POST | `/api/orgs/{orgId}/refund-cases` | SALES / ADMIN / OWNER / SYSTEM_ADMIN | 建立案件草稿 |
| GET | `/api/orgs/{orgId}/refund-cases/{id}` | MEMBER | 案件詳情 |
| PATCH | `/api/orgs/{orgId}/refund-cases/{id}` | SALES / ADMIN / OWNER / SYSTEM_ADMIN | 更新草稿案件 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/submit` | SALES / OWNER / SYSTEM_ADMIN | 送出案件 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/cancel` | SALES / OWNER / SYSTEM_ADMIN | 取消草稿 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/admin-approve` | ADMIN / OWNER / SYSTEM_ADMIN | 內勤審核通過 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/finance-confirm` | FINANCE / OWNER / SYSTEM_ADMIN | 財務確認 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/manager-approve` | MANAGER / OWNER / SYSTEM_ADMIN | 主管核准 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/reject` | MANAGER / OWNER / SYSTEM_ADMIN | 主管拒絕 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/return` | ADMIN / FINANCE / OWNER / SYSTEM_ADMIN | 退回補件 |
| POST | `/api/orgs/{orgId}/refund-cases/{id}/mark-paid` | FINANCE / OWNER / SYSTEM_ADMIN | 標記已退款 |
| GET | `/api/orgs/{orgId}/refund-cases/{id}/status-logs` | MEMBER | 案件狀態紀錄 |

### Create Refund Case Request

```json
{
  "clientId": 1,
  "projectId": 10,
  "refundReason": "CLIENT_CANCELLED",
  "refundAmount": 12000.00,
  "description": "客戶提前終止合作，申請部分退費。"
}
```

### Review Action Request

```json
{
  "comment": "資料確認完整，同意進入下一關。"
}
```

### Return Request

```json
{
  "comment": "請補上退款帳戶與合約終止證明。"
}
```

---

## Files

| Method | Path | Role | 說明 |
|---|---|---|---|
| POST | `/api/orgs/{orgId}/refund-cases/{id}/files` | AUTHORIZED | 上傳案件文件 |
| GET | `/api/orgs/{orgId}/refund-cases/{id}/files` | AUTHORIZED | 案件文件列表 |
| GET | `/api/orgs/{orgId}/files/{id}/download` | AUTHORIZED | 下載文件 |
| DELETE | `/api/orgs/{orgId}/files/{id}` | AUTHORIZED | 刪除文件 |

---

## Dashboard

| Method | Path | Role | 說明 |
|---|---|---|---|
| GET | `/api/orgs/{orgId}/dashboard/refund-summary` | ADMIN / FINANCE / MANAGER / OWNER / SYSTEM_ADMIN | 退費總覽 |
| GET | `/api/orgs/{orgId}/dashboard/status-count` | ADMIN / FINANCE / MANAGER / OWNER / SYSTEM_ADMIN | 狀態數量 |
| GET | `/api/orgs/{orgId}/dashboard/monthly-trend` | ADMIN / FINANCE / MANAGER / OWNER / SYSTEM_ADMIN | 月度趨勢 |
| GET | `/api/orgs/{orgId}/dashboard/reason-ranking` | ADMIN / FINANCE / MANAGER / OWNER / SYSTEM_ADMIN | 退費原因排行 |
| GET | `/api/orgs/{orgId}/dashboard/processing-time` | ADMIN / FINANCE / MANAGER / OWNER / SYSTEM_ADMIN | 平均處理時間 |

---

## AI / RAG

AI API 屬於第二階段。

| Method | Path | 說明 |
|---|---|---|
| POST | `/api/orgs/{orgId}/ai/documents/upload` | 上傳合約文件到 AI ingestion |
| POST | `/api/orgs/{orgId}/ai/documents/{id}/ingest` | 文件切 chunk 與 embedding |
| POST | `/api/orgs/{orgId}/ai/search` | 合約文件搜尋 |
| POST | `/api/orgs/{orgId}/ai/refund-cases/{id}/summary` | 案件摘要 |
| POST | `/api/orgs/{orgId}/ai/refund-cases/{id}/missing-documents-check` | 缺件提醒 |
