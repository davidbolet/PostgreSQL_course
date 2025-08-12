# Lab: Compare Connection Types & Patterns (JDBC vs R2DBC)

**Time:** 45–60 min • **Teams:** 2–3 students • **Goal:** Wire up JDBC with pooling and R2DBC; measure batching vs single inserts and streaming vs naive fetch.

## 0) Setup
- PostgreSQL running (Docker is fine).
- Java 17+, Maven.
- Create DB `myapp` and user `app_user` with rights.

```sql
CREATE ROLE app_user LOGIN PASSWORD 'secret';
CREATE DATABASE myapp;
GRANT CONNECT ON DATABASE myapp TO app_user;
```
## 1) JDBC + HikariCP baseline
1. Dependencies: pgjdbc + HikariCP.  
2. Create schema/table/index in `myapp`:
```sql
\c myapp
CREATE SCHEMA IF NOT EXISTS app;
CREATE TABLE IF NOT EXISTS app.items (
  id BIGSERIAL PRIMARY KEY,
  sku TEXT NOT NULL,
  payload JSONB,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_items_sku ON app.items(sku);
```
3. Insert **10k rows**:
   - A: **without** `reWriteBatchedInserts`  
   - B: **with** `reWriteBatchedInserts=true`
4. Measure total time for A vs B.

## 2) Streaming vs naive fetch (JDBC)
Read 10k rows:
- Naive: default fetch.
- Streaming: `setAutoCommit(false)` + `setFetchSize(1000)`.
Measure time and memory.

## 3) R2DBC quick test (optional)
- Add `r2dbc-postgresql` dependency.
- Connect and run a select with Reactor Flux.
- Compare experience vs JDBC.

## 4) PgBouncer note (if available)
Repeat Part 1 through PgBouncer; add `prepareThreshold=0&autosave=conservative` and note behavior.

## Deliverables
- Insert timings: A vs B.
- Fetch timings: naive vs streamed.
- Notes: which settings mattered most and why.
