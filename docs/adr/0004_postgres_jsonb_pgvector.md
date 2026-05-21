# ADR-0004 postgres_jsonb_pgvector

Date: 2026-05-20

## Context

ContractFlow 主要資料是關聯資料，但 Audit Log 需要保存 before / after snapshot。第二階段 AI / RAG 需要向量搜尋。

## Decision

採用 PostgreSQL 作為主資料庫：

1. 關聯資料使用一般 table。
2. Audit Log snapshot 使用 JSONB。
3. 第二階段使用 pgvector 儲存文件 chunk embedding。

## Consequences

優點：

1. MVP 不需要額外導入多種資料庫。
2. JSONB 適合保存稽核 snapshot。
3. pgvector 可支援作品集加分的 RAG 功能。

代價：

1. JSONB 不應濫用在核心可查詢欄位。
2. pgvector 屬於第二階段，需在部署環境安裝 extension。

