# Lab 5 — Shared vs Private Schemas (Compatibility Views)

**Scenario:** You are splitting a shared DB into private schemas.

```sql
CREATE TABLE billing.invoice (
  id            BIGSERIAL    PRIMARY KEY,
  tenant_id     BIGINT       NOT NULL,
  invoice_no    TEXT         NOT NULL,
  amount_cents  BIGINT       NOT NULL CHECK (amount_cents >= 0),
  currency      TEXT         NOT NULL CHECK (currency IN ('EUR','USD','GBP')),
  status        TEXT         NOT NULL CHECK (status IN ('draft','issued','void','cancelled')),
  due_date      DATE,
  issued_at     TIMESTAMPTZ,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, invoice_no)  -- business key per tenant
);
```

## Tasks
1) Create a `public.invoice` **VIEW** that selects from `billing.invoice`.  
3) Propose a **deprecation plan** for the old path.

## Validation
```sql
-- Should read rows transparently via the view
SELECT COUNT(*) FROM public.invoice;
```
