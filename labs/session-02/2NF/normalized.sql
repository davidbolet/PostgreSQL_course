CREATE TABLE products (
  product_id   BIGINT PRIMARY KEY,
  product_name TEXT NOT NULL,
  unit_price   NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE order_items (
  order_id   BIGINT NOT NULL,
  product_id BIGINT NOT NULL REFERENCES products(product_id),
  qty        INT    NOT NULL CHECK (qty > 0),
  PRIMARY KEY (order_id, product_id)
);


-- One row per product_id for product attributes
INSERT INTO products(product_id, product_name, unit_price)
SELECT product_id,
       MIN(product_name) AS product_name,  -- pick a representative value
       MIN(unit_price)   AS unit_price
FROM order_items_denorm
GROUP BY product_id;

-- Order lines keep only the qty and the product reference
INSERT INTO order_items(order_id, product_id, qty)
SELECT order_id, product_id, qty
FROM order_items_denorm;