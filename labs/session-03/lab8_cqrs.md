# Lab 8 — Read/Write Segregation (CQRS)

**Scenario:** Build a read model for the top orders dashboard.

## Tasks
1) Create `order_summary_mv` materialized view with `id` unique index.  
2) Write a `REFRESH MATERIALIZED VIEW CONCURRENTLY` command.  
3) Compare performance of reading from the MV vs a join query with `EXPLAIN ANALYZE`.

## Validation
```sql
EXPLAIN ANALYZE SELECT * FROM order_summary_mv ORDER BY total DESC LIMIT 20;
```
