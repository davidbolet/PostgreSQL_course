# Mini Lab — Fixing Third Normal Form (3NF) Violations

**Goal:** Remove **transitive dependencies** so that no non-key attribute depends on another non-key attribute.

## What is 3NF (recap)
- Already in 2NF.
- **No transitive dependencies**: non-key → non-key is not allowed. Every non-key depends **only** on the key.

---

## Setup
Run:
```sql
\i 01_denormalized_3NF_seed.sql
```

You will get two denormalized tables that violate 3NF:

1) `lab3nf.employees_denorm(emp_id PK, emp_name, dept_id, dept_name, location_id, location_name)`  
   - Transitive deps: `emp_id → dept_id → (dept_name, location_id)` and `location_id → location_name`.

2) `lab3nf.products_denorm(product_id PK, product_name, category_id, category_name, vat_rate)`  
   - Transitive deps: `product_id → category_id → (category_name, vat_rate)`.

---

## Your tasks

### Task A — Normalize Employees / Departments / Locations
Design tables:
- `lab3nf.locations(location_id PK, location_name UNIQUE)`
- `lab3nf.departments(dept_id PK, dept_name, location_id FK→locations)`
- `lab3nf.employees(emp_id PK, emp_name, dept_id FK→departments)`

Migrate data:
- Create `locations` from distinct `location_id` (choose a policy for naming conflicts: **mode()/MIN()**).
- Create `departments` from distinct `dept_id` (pick **dept_name** policy; keep `location_id`).
- Create `employees` referencing only `dept_id`.

### Task B — Normalize Products / Categories
Design tables:
- `lab3nf.categories(category_id PK, category_name, vat_rate)`
- `lab3nf.products(product_id PK, product_name, category_id FK→categories)`

Migrate data:
- Create `categories` from distinct `category_id` (policy for `category_name` conflicts: **mode()/MIN()**; choose one `vat_rate`, e.g., **AVG()**).
- Create `products` referencing only `category_id`.

### Constraints & Indexes (recommended)
- Add `NOT NULL` as appropriate; `UNIQUE` on `location_name` and maybe `category_name` (if business allows).
- Add indexes on foreign keys for joins — Postgres doesn’t auto-create them.

---

## Deliverables
- DDL for the normalized tables.
- Migration queries (`INSERT … SELECT`) for both tasks.
- 1–2 validation queries proving that transitive facts now live in one place.

## Validation ideas
- Conflicts should disappear from descriptor tables:
```sql
-- No multiple names per location_id
SELECT location_id, COUNT(*) FROM lab3nf.locations GROUP BY location_id HAVING COUNT(*) <> 1;

-- No multiple (name, vat_rate) per category_id
SELECT category_id, COUNT(*) FROM lab3nf.categories GROUP BY category_id HAVING COUNT(*) <> 1;
```

- Relationship counts preserved:
```sql
SELECT COUNT(*) FROM lab3nf.employees_denorm;  -- before
SELECT COUNT(*) FROM lab3nf.employees;         -- after

SELECT COUNT(*) FROM lab3nf.products_denorm;   -- before
SELECT COUNT(*) FROM lab3nf.products;          -- after
```

- Spot the transitive issues in the denormalized data (optional):
```sql
SELECT dept_id, COUNT(DISTINCT dept_name) AS dept_name_variants,
       COUNT(DISTINCT location_id) AS loc_variants
FROM lab3nf.employees_denorm
GROUP BY dept_id
HAVING COUNT(DISTINCT dept_name) > 1 OR COUNT(DISTINCT location_id) > 1;

SELECT location_id, COUNT(DISTINCT location_name) AS loc_name_variants
FROM lab3nf.employees_denorm
GROUP BY location_id
HAVING COUNT(DISTINCT location_name) > 1;
```

## Hints
- If `mode() WITHIN GROUP` isn't available, use `MIN()` for deterministic picks.
- Wrap migrations in a transaction (`BEGIN; … COMMIT;`).
- Explain to your team: **facts live once** (e.g., the city name lives in `locations`).

Good luck!
