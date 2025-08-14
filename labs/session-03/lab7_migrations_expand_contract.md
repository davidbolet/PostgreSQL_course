# Lab 7 — Expand–Contract Migration

**Scenario:** You need to add `total_cents` to `orders` without downtime.

## Tasks
1) **Expand:** `ALTER TABLE orders ADD COLUMN total_cents BIGINT;`  
2) Backfill in **chunks** (write the UPDATE pattern).  
3) Switch reads to the new column; dual-write in app.  
4) **Contract:** `ALTER TABLE orders ALTER COLUMN total_cents SET NOT NULL;`

## Validation
```sql
-- Chunking pattern
UPDATE orders
SET total_cents = sub.total
FROM (
  SELECT id, (SELECT SUM(qty*price*100) FROM order_items WHERE order_id=id) AS total
  FROM orders
  WHERE id > :last_id
  ORDER BY id
  LIMIT 1000
) sub
WHERE orders.id = sub.id;
```
