-- 2NF Mini-Lab — Reference Solution
-- Normalize partial dependencies so every non-key column depends on the whole key.

BEGIN;

-- ==========================
-- Task A: Orders / Products
-- ==========================

-- 1) Reference table for product descriptors
CREATE TABLE lab2nf.products (
  product_id   BIGINT PRIMARY KEY,
  product_name TEXT NOT NULL,
  unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

-- Choose a policy for conflicts: mode() for names, AVG price
-- If mode() isn't available, MIN() is fine for names.
INSERT INTO lab2nf.products(product_id, product_name, unit_price)
SELECT product_id,
       mode() WITHIN GROUP (ORDER BY product_name) AS product_name,
       AVG(unit_price)::numeric(10,2)              AS unit_price
FROM lab2nf.order_items_denorm
GROUP BY product_id;

-- 2) Normalized order_items
CREATE TABLE lab2nf.order_items (
  order_id   BIGINT NOT NULL,
  product_id BIGINT NOT NULL REFERENCES lab2nf.products(product_id),
  qty        INT    NOT NULL CHECK (qty > 0),
  PRIMARY KEY (order_id, product_id)
);

-- Migrate relationship rows
INSERT INTO lab2nf.order_items(order_id, product_id, qty)
SELECT order_id, product_id, qty
FROM lab2nf.order_items_denorm;

-- Helpful indexes
CREATE INDEX IF NOT EXISTS ix_order_items_product ON lab2nf.order_items(product_id);


-- ==============================
-- Task B: Enrollments / Students
-- ==============================

-- 1) Reference tables for descriptors
CREATE TABLE lab2nf.students (
  student_id   BIGINT PRIMARY KEY,
  student_name TEXT NOT NULL
);

CREATE TABLE lab2nf.courses (
  course_id    BIGINT PRIMARY KEY,
  course_title TEXT NOT NULL,
  dept         TEXT NOT NULL
);

-- Populate students and courses (one row per key)
INSERT INTO lab2nf.students(student_id, student_name)
SELECT student_id, mode() WITHIN GROUP (ORDER BY student_name)
FROM lab2nf.enrollment_denorm
GROUP BY student_id;

INSERT INTO lab2nf.courses(course_id, course_title, dept)
SELECT course_id,
       mode() WITHIN GROUP (ORDER BY course_title) AS course_title,
       mode() WITHIN GROUP (ORDER BY dept)         AS dept
FROM lab2nf.enrollment_denorm
GROUP BY course_id;

-- 2) Normalized enrollments
CREATE TABLE lab2nf.enrollments (
  student_id BIGINT NOT NULL REFERENCES lab2nf.students(student_id),
  course_id  BIGINT NOT NULL REFERENCES lab2nf.courses(course_id),
  grade      TEXT,
  PRIMARY KEY(student_id, course_id)
);

INSERT INTO lab2nf.enrollments(student_id, course_id, grade)
SELECT student_id, course_id, grade
FROM lab2nf.enrollment_denorm;

-- Helpful indexes
CREATE INDEX IF NOT EXISTS ix_enrollments_student ON lab2nf.enrollments(student_id);
CREATE INDEX IF NOT EXISTS ix_enrollments_course  ON lab2nf.enrollments(course_id);

COMMIT;

-- =================
-- Validations (ref)
-- =================

-- Relationship row counts preserved
SELECT (SELECT COUNT(*) FROM lab2nf.order_items_denorm) AS before_order_items,
       (SELECT COUNT(*) FROM lab2nf.order_items)        AS after_order_items;

SELECT (SELECT COUNT(*) FROM lab2nf.enrollment_denorm)  AS before_enrollments,
       (SELECT COUNT(*) FROM lab2nf.enrollments)        AS after_enrollments;

-- Each product_id maps to exactly one descriptor row
SELECT product_id, COUNT(*) AS rows
FROM lab2nf.products GROUP BY product_id HAVING COUNT(*) <> 1;

-- Each course_id maps to exactly one descriptor row
SELECT course_id, COUNT(*) AS rows
FROM lab2nf.courses GROUP BY course_id HAVING COUNT(*) <> 1;

-- Example join to show normalized reads
SELECT oi.order_id, p.product_name, p.unit_price, oi.qty, (oi.qty * p.unit_price) AS line_total
FROM lab2nf.order_items oi
JOIN lab2nf.products p USING (product_id)
ORDER BY oi.order_id, oi.product_id;
