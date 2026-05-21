# ADR-0001 auth_cookie_jwt_refresh_rotation

Date: 2026-05-20

## Context

ContractFlow 是 B2B 合約與退費審核 SaaS 平台，需要登入驗證、組織層級角色權限與可撤銷 session。前端會透過瀏覽器呼叫 API。

## Decision

採用 JWT Access Token + HttpOnly Cookie，Refresh Token 使用 rotation。MVP 先將 refresh token hash 存在 PostgreSQL，第二階段可加入 Redis。

## Consequences

優點：

1. HttpOnly Cookie 降低 token 被 JavaScript 讀取的風險。
2. Refresh rotation 可降低 refresh token 長期外洩風險。
3. 後端仍可撤銷 refresh token。

代價：

1. 使用 Cookie 驗證需設計 CSRF 防護。
2. Refresh token 狀態需要儲存與清理。
