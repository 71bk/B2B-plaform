# Backend Smoke Test Baseline

---

## Goal

Smoke test 用來快速確認本機或部署環境的核心流程可用，不取代完整自動化測試。

---

## Coverage

最小覆蓋範圍：

1. Backend health check。
2. Login。
3. `GET /api/auth/me`。
4. 建立或選擇 Organization。
5. 建立 client。
6. 建立 project。
7. 建立 contract。
8. 建立 refund case draft。
9. Submit refund case。
10. Admin approve。
11. Finance confirm。
12. Manager approve。
13. Finance mark paid。
14. 查詢 status logs。
15. 確認 audit logs 有資料。

---

## How To Run

MVP 階段可使用 Postman / Bruno / curl 手動測試。

第二階段可加入：

```text
mvn test
mvn verify
```

或建立 smoke test script。

---

## Expected Baseline Result

完整流程結束後：

1. 案件狀態應為 `PAID`。
2. `submitted_at`、`approved_at`、`paid_at` 不為空。
3. `refund_case_status_logs` 至少包含 submit、admin approve、finance confirm、manager approve、mark paid。
4. `operation_audit_logs` 包含案件建立與各審核操作。
5. Sales 不可呼叫 admin approve API。
6. 已 `PAID` 案件不可修改。
7. 不同 Organization 不可互相查詢 client、contract、refund case、file 與 audit log。

---

## CSRF Manual Smoke

若啟用 CSRF：

1. 呼叫 `GET /api/auth/csrf`。
2. 寫入型 API 帶上 `X-CSRF-TOKEN`。
3. 不帶 CSRF token 時應回傳 403。

---

## Version Conflict Smoke

測試同一案件同時審核：

1. 使用兩個 request 讀取同一案件版本。
2. 第一個 request 成功更新狀態。
3. 第二個 request 使用舊版本送出。
4. 預期回傳 `409 VERSION_CONFLICT`。
