-- 2NF Mini-Lab — Denormalized seed (intentionally violates 2NF)
-- Schema: lab2nf

DROP SCHEMA IF EXISTS lab2nf CASCADE;
CREATE SCHEMA lab2nf;

-- ===============================================
-- Scenario A: Order items with product attributes
-- ===============================================
-- PK is composite (order_id, product_id). Columns product_name and unit_price
-- depend ONLY on product_id (a part of the key) -> 2NF violation.
CREATE TABLE lab2nf.order_items_denorm (
  order_id     BIGINT NOT NULL,
  product_id   BIGINT NOT NULL,
  qty          INT    NOT NULL,
  product_name TEXT   NOT NULL,
  unit_price   NUMERIC(10,2) NOT NULL,
  PRIMARY KEY(order_id, product_id)
);

INSERT INTO lab2nf.order_items_denorm VALUES
(1001,10,2,'Widget',19.99),
(1002,10,1,'Widget',19.99),
(1003,11,3,'Gadget', 9.50),
(1004,10,5,'Widget A',18.99),   -- intentional conflict to show anomaly risk
(1005,12,1,'Doodad',14.00);

-- ===============================================
-- Scenario B: Enrollments with student and course descriptors
-- ===============================================
-- PK is composite (student_id, course_id). Columns student_name depends only
-- on student_id; course_title and dept depend only on course_id -> 2NF violation.
CREATE TABLE lab2nf.enrollment_denorm (
  student_id   BIGINT NOT NULL,
  course_id    BIGINT NOT NULL,
  grade        TEXT,
  student_name TEXT   NOT NULL,
  course_title TEXT   NOT NULL,
  dept         TEXT   NOT NULL,
  PRIMARY KEY(student_id, course_id)
);

INSERT INTO lab2nf.enrollment_denorm VALUES
(1,  101, 'A',  'Ada Lovelace',  'Databases', 'CS'),
(1,  102, 'B+', 'Ada Lovelace',  'Algorithms', 'CS'),
(2,  101, 'A-', 'Alan Turing',   'Databases', 'CS'),
(3,  201, 'B',  'Grace Hopper',  'Compilers', 'CS'),
(3,  202, 'A',  'Grace Hopper',  'Distributed Systems', 'CS');

-- Helpful queries for students to spot partial dependencies
-- (keep these as hints; not necessary to run)
-- SELECT product_id, COUNT(DISTINCT product_name), COUNT(DISTINCT unit_price)
-- FROM lab2nf.order_items_denorm GROUP BY product_id;
-- SELECT course_id, COUNT(DISTINCT course_title), COUNT(DISTINCT dept)
-- FROM lab2nf.enrollment_denorm GROUP BY course_id;
-- SELECT student_id, COUNT(DISTINCT student_name)
-- FROM lab2nf.enrollment_denorm GROUP BY student_id;
