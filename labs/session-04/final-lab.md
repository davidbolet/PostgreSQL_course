# Final Lab — PostgreSQL Query Tuning Round‑Up

A compact capstone lab that checks multiple concepts from the course without repeating the previous exercise.  
It introduces new schema, data, and queries to practice:

- Using `pg_stat_statements` & `auto_explain`  
- Identifying and fixing **non-sargable** predicates  
- Creating a **functional index** (`lower(email)`)  
- Using a **BRIN index** for time-series (`orders.created_at`)  
- Building a **composite index with INCLUDE** for join & aggregation  
- Creating **extended statistics** for correlated columns  
- Reading plans with `EXPLAIN (ANALYZE, BUFFERS)`  

---

## 📥 Downloads
- **SQL**: [final-lab.sql](sandbox:/mnt/data/final-lab.sql)  
- **Markdown**: this file

---

## 0) Prerequisites

- PostgreSQL 13+ (tested on 16).  
- Ensure `shared_preload_libraries` includes: `pg_stat_statements,auto_explain`  
- Enable extensions once per database:
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS auto_explain;
```
Optional (for visibility during lab):
```sql
SET auto_explain.log_min_duration = '300ms';
SET auto_explain.log_analyze = on;
SET auto_explain.log_buffers = on;
```

---

## 1) Run the SQL

Execute the lab script end‑to‑end:
```bash
psql -h <host> -U <user> -d <db> -f final-lab.sql
```

Or inside `psql`:
```sql
\i final-lab.sql
```

The script will:
1. Create schema **finallab** with `customers` and `orders` tables.  
2. Seed ~80k customers and ~300k orders.  
3. Run **baseline queries** with deliberate inefficiencies (non-sargable predicates, missing indexes).  
4. Create targeted indexes and extended statistics.  
5. Run rewritten queries to show improvements.  

---

## 2) What to Observe

For each query (B1–B3 vs R1–R3), record:
- Execution time (ms)  
- Scan type (Seq / Bitmap / Index / Index Only)  
- Buffers read vs hit  
- Rows scanned vs rows returned  

### Expected outcomes
- **R1**: Uses functional index on `lower(email)` instead of seq scan.  
- **R2**: Uses BRIN index to skip large time ranges.  
- **R3**: Better join plan using `(customer_id, created_at) INCLUDE (amount_cents)`.  
- Extended statistics improve row estimates for correlated columns.  

---

## 3) Optional Exploration

- Compare **BRIN vs BTREE** for `orders.created_at`:  
```sql
CREATE INDEX idx_orders_created_at_btree ON finallab.orders (created_at);
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM finallab.orders
WHERE created_at >= date_trunc('day', now() - interval '7 days')
  AND created_at <  date_trunc('day', now() - interval '6 days');
```

- Inspect query stats after several runs:
```sql
SELECT queryid, calls, mean_exec_time, rows
FROM pg_stat_statements
WHERE query ILIKE '%finallab.%'
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## 4) Cleanup (optional)
```sql
DROP SCHEMA finallab CASCADE;
```

---

**Prepared:** 2025-08-22
