-- 1NF Mini-Lab — Denormalized seed (intentionally violates 1NF)
-- Schema: lab1nf

DROP SCHEMA IF EXISTS lab1nf CASCADE;
CREATE SCHEMA lab1nf;

-- Violation A: repeating group stored as JSON array in a single column
CREATE TABLE lab1nf.orders_flat (
  order_id    BIGINT PRIMARY KEY,
  order_date  DATE NOT NULL,
  customer_id BIGINT NOT NULL,
  customer_name TEXT NOT NULL,
  items       JSONB NOT NULL       -- e.g., [{ "product_id": 10, "qty": 2 }, ...]
);

INSERT INTO lab1nf.orders_flat VALUES
(1001, '2025-01-10', 1, 'Ada Lovelace', '[{"product_id":10,"qty":2},{"product_id":11,"qty":1}]'),
(1002, '2025-01-11', 2, 'Alan Turing',  '[{"product_id":11,"qty":3}]'),
(1003, '2025-01-12', 3, 'Grace Hopper', '[{"product_id":10,"qty":1},{"product_id":12,"qty":4}]');

-- Violation B: multi-valued attribute stored as comma-separated list
CREATE TABLE lab1nf.customers_bad (
  customer_id BIGINT PRIMARY KEY,
  name        TEXT NOT NULL,
  phones      TEXT          -- e.g., '111,222'  (violates 1NF: not atomic)
);

INSERT INTO lab1nf.customers_bad VALUES
(1, 'Ada Lovelace', '111,222'),
(2, 'Alan Turing',  '333'),
(3, 'Grace Hopper', '444;555');  -- semicolon variant on purpose

-- Violation C: array column (OLTP anti-pattern here)
CREATE TABLE lab1nf.events_flat (
  event_id BIGSERIAL PRIMARY KEY,
  title    TEXT NOT NULL,
  tags     TEXT[] NOT NULL       -- e.g., ARRAY['db','postgres','1nf']
);

INSERT INTO lab1nf.events_flat(title, tags) VALUES
('Intro to Databases', ARRAY['db','basics','1nf']),
('Advanced Postgres',  ARRAY['postgres','jsonb','indexing']),
('Normalization Lab',  ARRAY['db','1nf','practice']);
