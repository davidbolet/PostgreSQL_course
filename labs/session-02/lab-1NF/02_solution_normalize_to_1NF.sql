-- 1NF Mini-Lab — Reference Solution
-- Normalize repeating groups into child tables and migrate data.

BEGIN;

-- A) Orders & Order Items
CREATE TABLE lab1nf.orders (
  order_id     BIGINT PRIMARY KEY,
  order_date   DATE NOT NULL,
  customer_id  BIGINT NOT NULL,
  customer_name TEXT NOT NULL
);

CREATE TABLE lab1nf.order_items (
  order_id   BIGINT NOT NULL REFERENCES lab1nf.orders(order_id),
  product_id BIGINT NOT NULL,
  qty        INT    NOT NULL CHECK (qty > 0),
  PRIMARY KEY (order_id, product_id)
);

-- Load parents
INSERT INTO lab1nf.orders(order_id, order_date, customer_id, customer_name)
SELECT order_id, order_date, customer_id, customer_name
FROM lab1nf.orders_flat;

-- Unnest JSON array to rows
INSERT INTO lab1nf.order_items(order_id, product_id, qty)
SELECT f.order_id,
       (e.elem->>'product_id')::bigint AS product_id,
       (e.elem->>'qty')::int           AS qty
FROM lab1nf.orders_flat f,
LATERAL jsonb_array_elements(f.items) AS e(elem);


-- B) Customers & Phones
CREATE TABLE lab1nf.customers (
  customer_id BIGINT PRIMARY KEY,
  name        TEXT NOT NULL
);

CREATE TABLE lab1nf.customer_phones (
  customer_id BIGINT NOT NULL REFERENCES lab1nf.customers(customer_id),
  phone       TEXT   NOT NULL,
  PRIMARY KEY (customer_id, phone)
);

-- Load customers
INSERT INTO lab1nf.customers(customer_id, name)
SELECT customer_id, name
FROM lab1nf.customers_bad;

-- Split on comma OR semicolon, trim spaces
INSERT INTO lab1nf.customer_phones(customer_id, phone)
SELECT b.customer_id, trim(x) AS phone
FROM lab1nf.customers_bad b,
     regexp_split_to_table(b.phones, '[,;]') AS x;


-- C) Events & Tags
CREATE TABLE lab1nf.events (
  event_id BIGINT PRIMARY KEY,
  title    TEXT NOT NULL
);

CREATE TABLE lab1nf.event_tags (
  event_id BIGINT NOT NULL REFERENCES lab1nf.events(event_id),
  tag      TEXT   NOT NULL,
  PRIMARY KEY (event_id, tag)
);

-- Load parents
INSERT INTO lab1nf.events(event_id, title)
SELECT event_id, title FROM lab1nf.events_flat;

-- Unnest array
INSERT INTO lab1nf.event_tags(event_id, tag)
SELECT event_id, unnest(tags) FROM lab1nf.events_flat;

COMMIT;

-- ---------- Quick validations ----------
-- Items count
SELECT
  (SELECT SUM(jsonb_array_length(items)) FROM lab1nf.orders_flat) AS flat_items,
  (SELECT COUNT(*) FROM lab1nf.order_items)                        AS normalized_items;

-- Phones count
SELECT
  (SELECT SUM( array_length( regexp_split_to_array(phones, '[,;]'), 1) ) FROM lab1nf.customers_bad) AS flat_phones,
  (SELECT COUNT(*) FROM lab1nf.customer_phones)                                                             AS normalized_phones;

-- Tags count
SELECT
  (SELECT SUM(array_length(tags,1)) FROM lab1nf.events_flat) AS flat_tags,
  (SELECT COUNT(*) FROM lab1nf.event_tags)                   AS normalized_tags;

-- Example join (now trivial):
SELECT o.order_id, o.customer_name, i.product_id, i.qty
FROM lab1nf.orders o
JOIN lab1nf.order_items i ON i.order_id = o.order_id
ORDER BY o.order_id, i.product_id;
