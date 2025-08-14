# Lab 1 — Good Schema Principles (Ownership & Invariants)

**Scenario:** You own the **Billing** service. Start with a draft schema:

```sql
CREATE SCHEMA billing;
CREATE TABLE billing.invoice_draft (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  invoice_no TEXT NOT NULL,
  amount_cents BIGINT NOT NULL,
  currency TEXT NOT NULL,
  status TEXT NOT NULL,
  lines JSONB NOT NULL -- list of {product_id, qty, price_cents}
);
```

## Tasks
1) Split `lines` into a child table; enforce `qty > 0`, and `(tenant_id, invoice_no)` unique.  
2) Add `CHECK (currency IN ('EUR','USD','GBP'))`.  
3) Model an **outbox** table to publish `invoice_issued` events when status becomes `issued`.  
4) Provide validation queries.

## Validation
```sql
-- One row per line; unique business key per tenant
SELECT COUNT(*) FROM billing.invoice;
SELECT COUNT(*) FROM billing.invoice_line;
SELECT tenant_id, invoice_no, COUNT(*) FROM billing.invoice GROUP BY 1,2 HAVING COUNT(*)>1;

-- Invariant checks
SELECT * FROM billing.invoice_line WHERE qty <= 0;
```
