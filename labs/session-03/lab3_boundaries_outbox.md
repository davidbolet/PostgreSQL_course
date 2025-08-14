# Lab 3 — Data Boundaries & Ownership (Outbox)

**Scenario:** When an order is paid, publish an `order_paid` event reliably.

## Tasks
1) Create `payment` table (id, order_id, amount_cents, status).  
2) Create `outbox(id, event_type, aggregate_id, payload, created_at, processed_at)`.  
3) Write a query to fetch unprocessed events in order.

## Validation
```sql
SELECT id, event_type, aggregate_id FROM outbox WHERE processed_at IS NULL ORDER BY id;
```
