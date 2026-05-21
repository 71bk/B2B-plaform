# Auth 與安全設計

---

## Cookie / JWT 策略

ContractFlow 使用 JWT + HttpOnly Cookie：

| Token | 用途 | 建議有效期 |
|---|---|---|
| Access Token | API 驗證 | 15 分鐘 |
| Refresh Token | 更新 Access Token | 7 天 |

Cookie 設定：

```text
HttpOnly=true
Secure=true
SameSite=Lax 或 Strict
```

若前後端跨站部署且必須使用 `SameSite=None`，需啟用 CSRF Token 與嚴格 CORS 白名單。

---

## 密碼雜湊策略

MVP 可使用 BCrypt：

```text
BCrypt strength: 10-12
```

第二階段可改 Argon2id。無論採用哪一種，資料庫只儲存 `password_hash`，不可儲存明文密碼。

---

## Refresh Rotation

Refresh Token 建議做 rotation：

1. 使用者登入後建立 refresh token。
2. 呼叫 `/api/auth/refresh` 時，舊 refresh token 作廢。
3. 系統簽發新的 access token 與 refresh token。
4. 若偵測到已撤銷 token 被重用，可撤銷該使用者所有 session。

MVP 可先存 PostgreSQL `refresh_tokens`，第二階段再改 Redis 或 PostgreSQL + Redis 混合。

---

## RBAC

角色：

```text
OWNER
SALES
ADMIN
FINANCE
MANAGER
SYSTEM_ADMIN
```

權限模型：

```text
User -> OrganizationMember -> Role -> Permission
```

Controller 可用 `@PreAuthorize` 做第一層檢查，Service 層仍需做 Organization membership 與資源層級檢查。

SaaS 授權原則：

1. 使用者可加入多個 Organization。
2. 同一使用者在不同 Organization 可有不同角色。
3. Tenant-owned API 使用 `/api/orgs/{orgId}/...` 傳入租戶 context。
4. 後端不可只信任前端傳入的 `orgId`，必須驗證目前使用者是該 Organization 的有效成員。
5. 所有 tenant-owned resource 查詢都必須帶 `organization_id` 條件。

---

## 資源層級權限

| 場景 | 規則 |
|---|---|
| Owner 管理組織 | 可管理同一 Organization 的成員、角色與設定 |
| Sales 查詢案件 | 只能查看同一 Organization 內自己建立的案件 |
| Sales 編輯案件 | 只能編輯同一 Organization 內自己的 `DRAFT` 案件 |
| Admin 審核 | 只能操作同一 Organization 的 `ADMIN_REVIEW` |
| Finance 審核 | 只能操作同一 Organization 的 `FINANCE_REVIEW` 或 `APPROVED -> PAID` |
| Manager 審核 | 只能操作同一 Organization 的 `MANAGER_REVIEW` |
| System Admin | 可管理平台資料，跨組織支援操作必須保留 Audit Log |

---

## CORS / CSRF

CORS：

1. 不允許 `*`。
2. 只允許指定前端網域。
3. 開啟 credentials 時需明確設定 allowed origins。

CSRF：

1. 同站部署優先使用 `SameSite=Lax` 或 `Strict`。
2. 跨站部署需使用 CSRF Token。
3. 寫入型 API 需驗證 `X-CSRF-TOKEN`。

---

## Rate Limit / Lockout

需要限制：

| API | 策略 |
|---|---|
| `/api/auth/login` | 依 IP + Email 限流 |
| `/api/auth/refresh` | 依 refresh token / user 限流 |
| 審核操作 | 可記錄頻率，避免重複提交 |

登入連續失敗可暫時鎖定帳號或要求稍後再試。

---

## Audit

安全相關操作需記錄：

1. 登入成功與失敗。
2. 登出。
3. Refresh token 旋轉與撤銷。
4. 角色變更。
5. 帳號啟用與停用。
6. Organization 成員邀請、停用與角色調整。
7. 權限不足或跨租戶存取嘗試可記錄 security warning。

---

## 安全檢查清單

- 密碼不可明文儲存。
- Cookie 必須 HttpOnly。
- Production Cookie 必須 Secure。
- CORS 不可允許任意 origin。
- 使用 Cookie 驗證時需有 CSRF 策略。
- Tenant-owned resource 必須檢查 `organization_id`。
- 不可讓使用者跨 Organization 存取資料。
- Service 層需做資源層級檢查。
- 重要操作需寫入 Audit Log。
