# Lab 2 — Normalization vs Denormalization (Read Model)

**Scenario:** The **Orders** service needs a fast endpoint: `/orders/{id}/summary`.

CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  order_number TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('draft','confirmed','shipped','cancelled')),
  UNIQUE (tenant_id, order_number)  -- business invariant
);

CREATE TABLE order_items (
  order_id BIGINT NOT NULL REFERENCES orders(id),
  product_id BIGINT NOT NULL,
  qty INT NOT NULL CHECK (qty > 0),
  price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  PRIMARY KEY (order_id, product_id)
);

## Tasks
1) Keep write model normalized: `orders`, `order_items`.  
2) Create a **materialized view** `order_summary_mv(id, total_cents, items_count)` with a unique index.  
3) Write a script of `REFRESH MATERIALIZED VIEW CONCURRENTLY order_summary_mv;` and validate with `EXPLAIN`.

## Validation
```sql
EXPLAIN ANALYZE SELECT * FROM order_summary_mv WHERE id = 42;
```
