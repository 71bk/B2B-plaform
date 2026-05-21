# AI / RAG 設計

> AI 功能屬於第二階段，不進入 MVP。

---

## 功能定位

ContractFlow 的 AI 不負責自動決策，只作為審核輔助工具。

AI 功能必須遵守 SaaS 多租戶隔離。文件 ingestion、embedding、RAG 查詢與案件摘要都需帶 `organization_id`，不可跨 Organization 檢索文件或歷史案件。

AI 可協助：

1. 合約條款搜尋。
2. 合約摘要。
3. 退費案件摘要。
4. 缺件提醒。
5. 歷史相似案件搜尋。
6. 退費原因分類建議。

---

## RAG 流程

```text
Upload Contract PDF
    ↓
Extract Text / OCR
    ↓
Chunk Text
    ↓
Generate Embeddings
    ↓
Store in pgvector
    ↓
User Query
    ↓
Retrieve Top-K Chunks
    ↓
LLM Answer with Citations
```

---

## AI Worker

建議使用 Python FastAPI 作為 AI Worker：

| API | 說明 |
|---|---|
| `POST /ingest` | 上傳文件並建立向量 |
| `POST /query` | RAG 查詢 |
| `POST /summary/refund-case` | 產生案件摘要 |
| `POST /missing-documents/check` | 缺件提醒 |

Spring Boot 後端負責權限、案件資料與 audit；AI Worker 只負責文件解析、embedding、retrieval 與 LLM 呼叫。

---

## pgvector schema

第二階段可拆出 `vector` schema：

```text
vector.rag_documents
vector.rag_chunks
```

`rag_documents` 儲存文件 metadata，`rag_chunks` 儲存 chunk text、embedding、source location。

建議欄位至少包含：

1. `organization_id`
2. `document_id`
3. `resource_type`
4. `resource_id`
5. `chunk_text`
6. `embedding`

---

## 查詢回應原則

AI 回答需包含：

1. answer。
2. citations。
3. source document。
4. chunk location。
5. confidence 或 retrieval score。

不可只回傳無來源的純文字答案。

---

## 風險限制

1. AI 不可直接核准或拒絕案件。
2. AI 回答需標示僅供參考。
3. 缺件提醒需回到規則或文件來源。
4. 敏感文件只允許有權限的使用者查詢。
5. AI Worker 不直接暴露給前端，統一由後端 API 代理。
6. Retrieval query 必須帶 `organization_id` filter。
