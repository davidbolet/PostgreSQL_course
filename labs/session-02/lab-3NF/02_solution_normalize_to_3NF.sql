-- 3NF Mini-Lab — Reference Solution
-- Normalize by extracting descriptor tables to kill transitive dependencies.

BEGIN;

-- ================================================
-- Task A: Employees / Departments / Locations
-- ================================================

-- 1) Descriptor tables
CREATE TABLE lab3nf.locations (
  location_id   INT PRIMARY KEY,
  location_name TEXT NOT NULL UNIQUE
);

INSERT INTO lab3nf.locations(location_id, location_name)
SELECT location_id,
       mode() WITHIN GROUP (ORDER BY location_name) AS location_name
FROM lab3nf.employees_denorm
GROUP BY location_id;

CREATE TABLE lab3nf.departments (
  dept_id     INT PRIMARY KEY,
  dept_name   TEXT NOT NULL,
  location_id INT NOT NULL REFERENCES lab3nf.locations(location_id)
);

INSERT INTO lab3nf.departments(dept_id, dept_name, location_id)
SELECT dept_id,
       mode() WITHIN GROUP (ORDER BY dept_name) AS dept_name,
       mode() WITHIN GROUP (ORDER BY location_id) AS location_id
FROM lab3nf.employees_denorm
GROUP BY dept_id;

-- 2) Main table, referencing only the key of descriptors
CREATE TABLE lab3nf.employees (
  emp_id   BIGINT PRIMARY KEY,
  emp_name TEXT NOT NULL,
  dept_id  INT NOT NULL REFERENCES lab3nf.departments(dept_id)
);

INSERT INTO lab3nf.employees(emp_id, emp_name, dept_id)
SELECT emp_id, emp_name, dept_id
FROM lab3nf.employees_denorm;

-- Helpful indexes
CREATE INDEX IF NOT EXISTS ix_employees_dept ON lab3nf.employees(dept_id);


-- ==========================================
-- Task B: Products / Categories (3NF split)
-- ==========================================

CREATE TABLE lab3nf.categories (
  category_id   INT PRIMARY KEY,
  category_name TEXT NOT NULL,
  vat_rate      NUMERIC(4,1) NOT NULL CHECK (vat_rate >= 0)
);

INSERT INTO lab3nf.categories(category_id, category_name, vat_rate)
SELECT category_id,
       mode() WITHIN GROUP (ORDER BY category_name) AS category_name,
       AVG(vat_rate)::NUMERIC(4,1)                  AS vat_rate
FROM lab3nf.products_denorm
GROUP BY category_id;

CREATE TABLE lab3nf.products (
  product_id   BIGINT PRIMARY KEY,
  product_name TEXT NOT NULL,
  category_id  INT NOT NULL REFERENCES lab3nf.categories(category_id)
);

INSERT INTO lab3nf.products(product_id, product_name, category_id)
SELECT product_id, product_name, category_id
FROM lab3nf.products_denorm;

CREATE INDEX IF NOT EXISTS ix_products_category ON lab3nf.products(category_id);

COMMIT;

-- ===================
-- Validations (ref)
-- ===================

-- No duplicate descriptor rows per key
SELECT location_id, COUNT(*) AS rows FROM lab3nf.locations GROUP BY location_id HAVING COUNT(*) <> 1;
SELECT dept_id,     COUNT(*) AS rows FROM lab3nf.departments GROUP BY dept_id HAVING COUNT(*) <> 1;
SELECT category_id, COUNT(*) AS rows FROM lab3nf.categories GROUP BY category_id HAVING COUNT(*) <> 1;

-- Relationship row counts preserved
SELECT (SELECT COUNT(*) FROM lab3nf.employees_denorm) AS before_employees,
       (SELECT COUNT(*) FROM lab3nf.employees)        AS after_employees;

SELECT (SELECT COUNT(*) FROM lab3nf.products_denorm)  AS before_products,
       (SELECT COUNT(*) FROM lab3nf.products)         AS after_products;

-- Example join now clean and consistent
SELECT e.emp_id, e.emp_name, d.dept_name, l.location_name
FROM lab3nf.employees e
JOIN lab3nf.departments d USING (dept_id)
JOIN lab3nf.locations   l ON l.location_id = d.location_id
ORDER BY e.emp_id;
