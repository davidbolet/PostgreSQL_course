-- 01_seed_denormalized.sql
CREATE SCHEMA IF NOT EXISTS lab;

-- 1NF violations
CREATE TABLE IF NOT EXISTS lab.orders_flat (
  order_id    BIGINT PRIMARY KEY,
  order_date  DATE NOT NULL,
  customer_id BIGINT NOT NULL,
  items       JSONB NOT NULL
);
INSERT INTO lab.orders_flat VALUES
(1001,'2025-01-10',1,'[{"product_id":10,"qty":2},{"product_id":11,"qty":1}]'::jsonb),
(1002,'2025-01-11',2,'[{"product_id":11,"qty":3}]'::jsonb);

CREATE TABLE IF NOT EXISTS lab.customers_bad (
  customer_id BIGINT PRIMARY KEY,
  name        TEXT NOT NULL,
  phones      TEXT
);
INSERT INTO lab.customers_bad VALUES
(1,'Ada Lovelace','111,222'),
(2,'Alan Turing','333'),
(3,'Grace Hopper','444;555');

-- 2NF violation
CREATE TABLE IF NOT EXISTS lab.order_items_denorm (
  order_id     BIGINT NOT NULL,
  product_id   BIGINT NOT NULL,
  qty          INT    NOT NULL,
  product_name TEXT   NOT NULL,
  unit_price   NUMERIC(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id)
);
INSERT INTO lab.order_items_denorm VALUES
(1001,10,2,'Widget',19.99),
(1002,10,1,'Widget',19.99),
(1003,11,3,'Gadget', 9.50),
(1004,10,5,'Widget A',18.99);

-- 3NF violation
CREATE TABLE IF NOT EXISTS lab.employees_denorm (
  emp_id        BIGINT PRIMARY KEY,
  emp_name      TEXT   NOT NULL,
  dept_id       INT    NOT NULL,
  dept_name     TEXT   NOT NULL,
  location_id   INT    NOT NULL,
  location_name TEXT   NOT NULL
);
INSERT INTO lab.employees_denorm VALUES
(1,'Ada Lovelace',   10,'Engineering',  1,'HQ'),
(2,'Alan Turing',    10,'Engineering',  1,'Headquarters'),
(3,'Grace Hopper',   20,'Research',     2,'Research Park'),
(4,'Edsger Dijkstra',20,'R&D',          2,'Research Park');
