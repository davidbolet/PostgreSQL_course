# Lab 6 — Naming Conventions & Consistency

**Scenario:** Audit and fix the following schema:

```sql
CREATE TABLE Cust (
  CustID BIGSERIAL PRIMARY KEY,
  Email TEXT UNIQUE,
  created TIMESTAMP,
  upd TIMESTAMP
);
CREATE TABLE OrderTbl (
  ID BIGSERIAL PRIMARY KEY,
  Cid BIGINT REFERENCES Cust(CustID),
  QTY INT,
  Product BIGINT
);
```

## Tasks
1) Rename tables/columns to snake_case; use `created_at/updated_at TIMESTAMPTZ`.  
2) Rename FKs to `<entity>_id`.  
3) Add `CHECK (qty > 0)` and a composite unique `(customer_id, id)` only if required.

## Validation
```sql
-- Verify new names and constraints exist
\d+ customer
\d+ order
```
