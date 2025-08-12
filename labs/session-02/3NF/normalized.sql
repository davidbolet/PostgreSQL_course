-- If a city_id maps to multiple city names, you’ve got a transitive dependency issue:
SELECT city_id, COUNT(DISTINCT city_name) AS name_variants,
       ARRAY_AGG(DISTINCT city_name)      AS names
FROM demo3nf.customers_denorm
GROUP BY city_id
HAVING COUNT(DISTINCT city_name) > 1;

-- Descriptor table: one row per city (the "fact" lives here)
CREATE TABLE demo3nf.cities (
  city_id   BIGINT PRIMARY KEY,
  city_name TEXT NOT NULL UNIQUE
);

-- Move each city_id to one row. If inconsistent names exist,
-- pick a deterministic policy: mode()/min()/max(). Here: choose the most common (mode).
INSERT INTO demo3nf.cities(city_id, city_name)
SELECT city_id,
       mode() WITHIN GROUP (ORDER BY city_name) AS city_name
FROM demo3nf.customers_denorm
GROUP BY city_id;

-- Main table: each customer references a city_id; no city_name stored here
CREATE TABLE demo3nf.customers (
  customer_id BIGINT PRIMARY KEY,
  name        TEXT   NOT NULL,
  city_id     BIGINT NOT NULL REFERENCES demo3nf.cities(city_id)
);

INSERT INTO demo3nf.customers(customer_id, name, city_id)
SELECT customer_id, name, city_id
FROM demo3nf.customers_denorm;