-- 02_solution_reference.sql
BEGIN;

-- 1NF fixes
CREATE TABLE IF NOT EXISTS lab.orders (
  order_id BIGINT PRIMARY KEY,
  order_date DATE NOT NULL,
  customer_id BIGINT NOT NULL
);
CREATE TABLE IF NOT EXISTS lab.order_items (
  order_id BIGINT NOT NULL REFERENCES lab.orders(order_id),
  product_id BIGINT NOT NULL,
  qty INT NOT NULL CHECK (qty > 0),
  PRIMARY KEY (order_id, product_id)
);
INSERT INTO lab.orders(order_id, order_date, customer_id)
SELECT order_id, order_date, customer_id FROM lab.orders_flat
ON CONFLICT (order_id) DO NOTHING;
INSERT INTO lab.order_items(order_id, product_id, qty)
SELECT f.order_id, (e.elem->>'product_id')::bigint, (e.elem->>'qty')::int
FROM lab.orders_flat f, LATERAL jsonb_array_elements(f.items) AS e(elem)
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS lab.customers (
  customer_id BIGINT PRIMARY KEY,
  name TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS lab.customer_phones (
  customer_id BIGINT NOT NULL REFERENCES lab.customers(customer_id),
  phone TEXT NOT NULL,
  PRIMARY KEY (customer_id, phone)
);
INSERT INTO lab.customers(customer_id, name)
SELECT customer_id, name FROM lab.customers_bad
ON CONFLICT (customer_id) DO NOTHING;
INSERT INTO lab.customer_phones(customer_id, phone)
SELECT b.customer_id, trim(x) FROM lab.customers_bad b, regexp_split_to_table(b.phones, '[,;]') AS x
ON CONFLICT DO NOTHING;

-- 2NF fix
CREATE TABLE IF NOT EXISTS lab.products (
  product_id BIGINT PRIMARY KEY,
  product_name TEXT NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);
CREATE TABLE IF NOT EXISTS lab.order_items_2nf (
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL REFERENCES lab.products(product_id),
  qty INT NOT NULL CHECK (qty > 0),
  PRIMARY KEY (order_id, product_id)
);
INSERT INTO lab.products(product_id, product_name, unit_price)
SELECT product_id, MIN(product_name), AVG(unit_price)::numeric(10,2)
FROM lab.order_items_denorm GROUP BY product_id
ON CONFLICT (product_id) DO NOTHING;
INSERT INTO lab.order_items_2nf(order_id, product_id, qty)
SELECT order_id, product_id, qty FROM lab.order_items_denorm
ON CONFLICT DO NOTHING;

-- 3NF fix
CREATE TABLE IF NOT EXISTS lab.locations (
  location_id INT PRIMARY KEY,
  location_name TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS lab.departments (
  dept_id INT PRIMARY KEY,
  dept_name TEXT NOT NULL,
  location_id INT NOT NULL REFERENCES lab.locations(location_id)
);
CREATE TABLE IF NOT EXISTS lab.employees (
  emp_id BIGINT PRIMARY KEY,
  emp_name TEXT NOT NULL,
  dept_id INT NOT NULL REFERENCES lab.departments(dept_id)
);
INSERT INTO lab.locations(location_id, location_name)
SELECT location_id, MIN(location_name) FROM lab.employees_denorm GROUP BY location_id
ON CONFLICT (location_id) DO NOTHING;
INSERT INTO lab.departments(dept_id, dept_name, location_id)
SELECT dept_id, MIN(dept_name), MIN(location_id) FROM lab.employees_denorm GROUP BY dept_id
ON CONFLICT (dept_id) DO NOTHING;
INSERT INTO lab.employees(emp_id, emp_name, dept_id)
SELECT emp_id, emp_name, dept_id FROM lab.employees_denorm
ON CONFLICT (emp_id) DO NOTHING;

COMMIT;
