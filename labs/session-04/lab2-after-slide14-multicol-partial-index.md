# Lab: Multi-Column & Partial Indexes (PostgreSQL) — After Slide 14

This lab gives you hands‑on practice with **multi-column** and **partial** indexes. You will:
1) Load sample data,  
2) Run intentionally slow queries to capture a **baseline**,  
3) Create targeted indexes,  
4) Measure improvements with `EXPLAIN (ANALYZE, BUFFERS)` and `pg_stat_statements`.

> Estimated time: 30–40 minutes

---

## 🎯 Download the Files

- SQL script (run end-to-end in `psql`):  
  **[lab-after-slide14.sql](lab-after-slide14.sql)**
- This Markdown instructions file: keep as a reference while running the SQL.

---

## 0) Prerequisites

- PostgreSQL 13+ (works on 16 as used in class).  
- `shared_preload_libraries` includes: `pg_stat_statements,auto_explain`  
  - Docker: start the container with `-c shared_preload_libraries=pg_stat_statements,auto_explain`
  - Local: edit `postgresql.conf` and restart the server.
- Enable extensions (run once per database):
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS auto_explain;
```

Quick checks:
```sql
SHOW shared_preload_libraries;           -- should include pg_stat_statements, auto_explain
\dx                                     -- both extensions listed
```

Optional (recommended during the lab):
```sql
SET auto_explain.log_min_duration = '300ms';  -- log plans over 300ms
SET auto_explain.log_analyze = on;
SET auto_explain.log_buffers = on;
```

---

## 1) Use the SQL Script

Do not execute whe whole sql file. First create the schema and run queries without indexes:


The script will:
- Create schema and tables, seed ~200k orders and ~600k–900k items.
- Run **baseline** `EXPLAIN (ANALYZE, BUFFERS)` on three queries (Q1–Q3).
- Create a **multi‑column** index, a **partial** index, and a **join helper** index.
- Run the same queries again to compare plans/timings.

---

## 2) What to Observe

For each query, compare **before vs after**:
- Execution time (ms)
- Scan type (Seq/Bitmap/Index/Index Only)
- Sort operations eliminated?
- Buffers: fewer reads after indexing
- Rows scanned vs rows returned (improved selectivity)

### Q1. Tenant feed (recent orders)
Pattern: `WHERE tenant_id = ? ORDER BY created_at DESC LIMIT 20`  
**Goal:** See index on `(tenant_id, created_at DESC)` used for order-by and filtering.

### Q2. Active orders by tenant (last 30 days)
Pattern: `WHERE status='active' AND tenant_id=? AND created_at >= now()-30d`  
**Goal:** Partial index on active rows reduces index size; expect faster lookups and scans.

### Q3. Join: Recent orders + items
Pattern: filter on `orders` by time, join to `order_items`.  
**Goal:** With `order_items(order_id)`, avoid scanning all items; expect bitmap/index probes.

---

## 3) Optional Exploration

- Flip index order to `(created_at, tenant_id)` and measure the impact on Q1.  
- Try an `INCLUDE` to enable index-only scans for your specific SELECT list.  
- Examine `pg_stat_statements` after multiple runs:
```sql
SELECT queryid, calls, mean_exec_time, rows
FROM pg_stat_statements
WHERE query ILIKE '%lab14.%'
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## 4) Cleanup (optional)
```sql
DROP SCHEMA lab14 CASCADE;
```

---

**Files:**  
- SQL: **[lab-after-slide14.sql](sandbox:/mnt/data/lab-after-slide14.sql)**  
- Markdown: this file
