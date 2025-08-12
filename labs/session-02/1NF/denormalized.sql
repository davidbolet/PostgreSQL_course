-- Start fresh (for demo)
DROP SCHEMA IF EXISTS demo CASCADE;
CREATE SCHEMA demo;

-- One big table: repeating group in 'items' (violates 1NF)
CREATE TABLE demo.orders_flat (
  order_id   BIGINT PRIMARY KEY,
  order_date DATE NOT NULL,
  customer   TEXT NOT NULL,
  items      JSONB NOT NULL  -- JSON array of {product_id, qty}
);

INSERT INTO demo.orders_flat VALUES
(1001,'2025-01-10','Ada Lovelace',
  '[{"product_id":10,"qty":2},{"product_id":11,"qty":1}]'),
(1002,'2025-01-11','Alan Turing',
  '[{"product_id":11,"qty":3}]');