# Mini Lab — Fixing First Normal Form (1NF) Violations

**Goal:** Practice spotting and fixing **1NF** violations by splitting repeating groups into child tables and ensuring columns are **atomic**.

## What is 1NF (quick recap)
- Each column contains **one** value (atomic), not lists or sets.
- No repeating groups in a row (e.g., no `items` arrays, no `phone1/phone2` columns).
- One fact lives in one place; child tables hold repeated elements.

---

## Provided starting point (denormalized)
Run:
```sql
\i 01_denormalized_seed.sql
```

You will get three tables with 1NF violations:

1. `lab1nf.orders_flat` — an `items` **JSONB array** per order.
2. `lab1nf.customers_bad` — `phones` stored as a **comma/semicolon-separated** string.
3. `lab1nf.events_flat` — `tags` stored as a **TEXT[] array**.

---

## Your tasks

### Task A — Orders & Order Items
- Create normalized tables:
  - `lab1nf.orders(order_id PK, order_date, customer_id, customer_name)`
  - `lab1nf.order_items(order_id FK→orders, product_id, qty, PK(order_id, product_id))`
- **Migrate** data:
  - Use `jsonb_array_elements(items)` to create **one row per item**.
- Add constraints: `NOT NULL` as appropriate and `CHECK (qty > 0)`.

### Task B — Customers & Phones
- Create normalized tables:
  - `lab1nf.customers(customer_id PK, name)`
  - `lab1nf.customer_phones(customer_id FK→customers, phone, PK(customer_id, phone))`
- **Migrate** data:
  - Split `phones` using `regexp_split_to_table(phones, '[,;]')`.
  - Trim whitespace around each phone.

### Task C — Events & Tags
- Create normalized tables:
  - `lab1nf.events(event_id PK, title)`
  - `lab1nf.event_tags(event_id FK→events, tag, PK(event_id, tag))`
- **Migrate** data:
  - Use `unnest(tags)` to create one row per tag.

---

## Deliverables
1. DDL for the normalized tables.
2. `INSERT ... SELECT` migration queries for each task.
3. A couple of **validation queries** that prove the row counts match before/after.

### Hints
- Use `LATERAL` with `jsonb_array_elements` for the orders items.
- Use `regexp_split_to_table` with the pattern `[,;]` to split both commas and semicolons.
- Use `trim(...)` to remove spaces from phone values.
- Add `FOREIGN KEY` constraints and `CHECK` constraints where sensible.

---

## Validation ideas (examples you can adapt)
- Items count before vs after:
  ```sql
  -- expected: number of elements in arrays equals rows in order_items
  SELECT SUM(jsonb_array_length(items)) AS flat_items
  FROM lab1nf.orders_flat;

  SELECT COUNT(*) AS normalized_items
  FROM lab1nf.order_items;
  ```
- Phone counts:
  ```sql
  SELECT SUM( array_length( regexp_split_to_array(phones, '[,;]'), 1) ) AS flat_phones
  FROM lab1nf.customers_bad;

  SELECT COUNT(*) AS normalized_phones
  FROM lab1nf.customer_phones;
  ```

> When you are done, you should be able to query orders and join their items, list customers and **each** of their phones, and search events by tag without parsing arrays or strings.

Good luck and have fun!
