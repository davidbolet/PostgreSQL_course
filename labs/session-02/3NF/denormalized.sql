DROP SCHEMA IF EXISTS demo3nf CASCADE;
CREATE SCHEMA demo3nf;

-- Violates 3NF: city_name depends on city_id (non-key → non-key),
-- and city_id depends on customer_id (the key).
CREATE TABLE demo3nf.customers_denorm (
  customer_id BIGINT PRIMARY KEY,
  name        TEXT   NOT NULL,
  city_id     BIGINT NOT NULL,
  city_name   TEXT   NOT NULL
);

INSERT INTO demo3nf.customers_denorm VALUES
  (1, 'Ada Lovelace', 501, 'London'),
  (2, 'Alan Turing',  502, 'Manchester'),
  (3, 'Grace Hopper', 501, 'London'),
  -- intentional inconsistency for teaching:
  (4, 'Edsger Dijkstra', 502, 'Mcr');  -- same city_id, different name