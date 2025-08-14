# Lab 4 — FK Strategies Across Services

**Scenario:** `order_items.product_id` refers to a Product owned by another service.

## Tasks
1) Create local FK for `order_items.order_id → orders.id`.  
2) Create `product_ref(product_id, name, version)` and insert 3 sample rows.  
3) Write a **reconciliation query** to find `order_items.product_id` that do not exist in `product_ref`.  
4) Propose an alerting policy based on the reconciliation.

## Validation
```sql
SELECT DISTINCT oi.product_id FROM order_items oi LEFT JOIN product_ref pr USING(product_id) WHERE pr.product_id IS NULL;
```
