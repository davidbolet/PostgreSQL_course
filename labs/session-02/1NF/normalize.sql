-- Parent table: one row per order
CREATE TABLE demo.orders (
  order_id   BIGINT PRIMARY KEY,
  order_date DATE NOT NULL,
  customer   TEXT NOT NULL
);

-- Child table: one row per item (atomic values)
CREATE TABLE demo.order_items (
  order_id   BIGINT NOT NULL REFERENCES demo.orders(order_id),
  product_id BIGINT NOT NULL,
  qty        INT    NOT NULL CHECK (qty > 0),
  PRIMARY KEY (order_id, product_id)
);

-- Migrate data from the violating table:
-- Unnest each array element into a row
INSERT INTO demo.orders (order_id, order_date, customer)
SELECT order_id, order_date, customer
FROM demo.orders_flat;

INSERT INTO demo.order_items (order_id, product_id, qty)
SELECT f.order_id,
       (i.elem->>'product_id')::bigint AS product_id,
       (i.elem->>'qty')::int           AS qty
FROM demo.orders_flat f,
     LATERAL jsonb_array_elements(f.items) AS i(elem);