# Mini Lab — Fixing Second Normal Form (2NF) Violations

**Goal:** Practice identifying **partial dependencies** and splitting attributes so that every non-key column depends on the **whole** primary key (not just part of it). Remember: 2NF applies when the primary key is **composite**.

## What you start with
Run:
```sql
\i 01_denormalized_2NF_seed.sql
```
You get two tables that **violate 2NF**:
1. `lab2nf.order_items_denorm(order_id, product_id, qty, product_name, unit_price)`  
   - PK: `(order_id, product_id)`  
   - **Violation:** `product_name`, `unit_price` depend only on `product_id`.
2. `lab2nf.enrollment_denorm(student_id, course_id, grade, student_name, course_title, dept)`  
   - PK: `(student_id, course_id)`  
   - **Violation:** `student_name` depends only on `student_id`; `course_title`, `dept` depend only on `course_id`.

---

## Your tasks

### Task A — Normalize `order_items_denorm`
1. Create a reference table:
   - `lab2nf.products(product_id PK, product_name, unit_price)`
2. Create a normalized table:
   - `lab2nf.order_items(order_id, product_id, qty, PK(order_id, product_id), FK product_id→products)`
3. **Migrate** data:
   - Insert one row per `product_id` into `products`. Pick a policy to resolve conflicting names/prices (e.g., `mode()`/`min()` for names, `avg()` or `max()` for prices).
   - Insert `(order_id, product_id, qty)` into `order_items` from the denormalized table.
4. Add constraints: `NOT NULL`, `CHECK (qty > 0)` and helpful indexes on FKs.

### Task B — Normalize `enrollment_denorm`
1. Create reference tables:
   - `lab2nf.students(student_id PK, student_name)`
   - `lab2nf.courses(course_id PK, course_title, dept)`
2. Create a normalized table:
   - `lab2nf.enrollments(student_id FK→students, course_id FK→courses, grade, PK(student_id, course_id))`
3. **Migrate** data:
   - Insert distinct students and courses from the denormalized table.
   - Insert enrollments with `(student_id, course_id, grade)`.
4. Add constraints: `NOT NULL` where reasonable (`student_name`, `course_title`, `dept`), and FK indexes.

---

## Deliverables
- DDL for the new normalized tables.
- `INSERT ... SELECT` migration queries for both tasks.
- A short note explaining how your design removes **partial dependencies**.

## Validation ideas
- Check for descriptor uniqueness after normalization:
  ```sql
  -- Each product_id should map to exactly one (name, price)
  SELECT product_id, COUNT(*) AS rows
  FROM lab2nf.products GROUP BY product_id HAVING COUNT(*) <> 1;

  -- Each course_id should map to exactly one (title, dept)
  SELECT course_id, COUNT(*) AS rows
  FROM lab2nf.courses GROUP BY course_id HAVING COUNT(*) <> 1;
  ```
- Row counts preserved for relationships:
  ```sql
  -- order lines count is preserved
  SELECT COUNT(*) FROM lab2nf.order_items_denorm;   -- before
  SELECT COUNT(*) FROM lab2nf.order_items;          -- after

  -- enrollment lines count is preserved
  SELECT COUNT(*) FROM lab2nf.enrollment_denorm;    -- before
  SELECT COUNT(*) FROM lab2nf.enrollments;          -- after
  ```
- Spot-the-violation queries (optional):
  ```sql
  -- Red flags in denormalized data: multiple names/prices per product
  SELECT product_id, COUNT(DISTINCT product_name) AS name_variants,
         COUNT(DISTINCT unit_price)   AS price_variants
  FROM lab2nf.order_items_denorm GROUP BY product_id
  HAVING COUNT(DISTINCT product_name) > 1 OR COUNT(DISTINCT unit_price) > 1;
  ```

## Hints
- If `mode() WITHIN GROUP` isn't available in your environment, use `MIN()`/`MAX()` for deterministic picks.
- Create indexes on foreign keys for faster joins (Postgres does **not** auto-create FK indexes).
- Keep transactions short; you can wrap the migration in a single `BEGIN; ... COMMIT;` block.
