-- 3NF Mini-Lab — Denormalized seed (intentionally violates 3NF)
-- Schema: lab3nf
-- Scenarios: Employees–Departments–Locations, and Products–Categories

DROP SCHEMA IF EXISTS lab3nf CASCADE;
CREATE SCHEMA lab3nf;

-- =====================================================
-- Scenario A: Employees with dept/location descriptors
-- =====================================================
-- PK is a single column (emp_id). Transitive dependencies:
--   emp_id → dept_id
--   dept_id → dept_name, location_id
--   location_id → location_name
-- Therefore: emp_id transitively determines location_name and dept_name.
CREATE TABLE lab3nf.employees_denorm (
  emp_id        BIGINT PRIMARY KEY,
  emp_name      TEXT   NOT NULL,
  dept_id       INT    NOT NULL,
  dept_name     TEXT   NOT NULL,
  location_id   INT    NOT NULL,
  location_name TEXT   NOT NULL
);

INSERT INTO lab3nf.employees_denorm VALUES
(1, 'Ada Lovelace',    10, 'Engineering',  1, 'HQ'),
(2, 'Alan Turing',     10, 'Engineering',  1, 'Headquarters'),  -- same location_id, different name
(3, 'Grace Hopper',    20, 'Research',     2, 'Research Park'),
(4, 'Edsger Dijkstra', 20, 'R&D',          2, 'Research Park'); -- same dept_id, name variant

-- ==============================================
-- Scenario B: Products with category descriptors
-- ==============================================
-- PK is product_id. Transitive dependencies:
--   product_id → category_id
--   category_id → category_name, vat_rate
-- Therefore: product_id transitively determines category_name and vat_rate.
CREATE TABLE lab3nf.products_denorm (
  product_id    BIGINT PRIMARY KEY,
  product_name  TEXT   NOT NULL,
  category_id   INT    NOT NULL,
  category_name TEXT   NOT NULL,
  vat_rate      NUMERIC(4,1) NOT NULL      -- percent (e.g., 21.0)
);

INSERT INTO lab3nf.products_denorm VALUES
(100, 'Laptop 14', 200, 'Electronics', 21.0),
(101, 'Mouse',     200, 'Elec',        20.0),  -- deliberate variants for same category_id
(102, 'Blender',   201, 'Home',        10.0);
