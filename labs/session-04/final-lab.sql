-- Final Lab (Compact): PostgreSQL Query Tuning Round-Up
-- Covers: pg_stat_statements, auto_explain, sargability, functional & partial indexes,
-- BRIN for time-series, extended statistics, INCLUDE indexes, and plan reading.

\timing on

-- ==============================
-- 0) Prep (optional)
-- ==============================
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- CREATE EXTENSION IF NOT EXISTS auto_explain;
-- SELECT pg_stat_statements_reset();

-- ==============================
-- 1) Schema & Data
-- ==============================
DROP SCHEMA IF EXISTS finallab CASCADE;
CREATE SCHEMA finallab;
SET search_path TO finallab, public;

CREATE TABLE finallab.customers (
  id           BIGSERIAL PRIMARY KEY,
  email        TEXT NOT NULL,
  country      TEXT NOT NULL,
  status       TEXT NOT NULL CHECK (status IN ('prospect','active','churned')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE finallab.orders (
  id           BIGSERIAL PRIMARY KEY,
  customer_id  BIGINT NOT NULL REFERENCES finallab.customers(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  amount_cents INT NOT NULL,
  state        TEXT NOT NULL CHECK (state IN ('new','paid','shipped','cancelled'))
);

-- Data: ~80k customers; ~300k orders
WITH p AS (SELECT 80000 AS n_customers),
ins_c AS (
  INSERT INTO finallab.customers (email, country, status, created_at)
  SELECT
    'user'||g::text||'@example.com',
    (ARRAY['ES','FR','DE','IT','US','GB','BR','MX'])[1+floor(random()*8)::int],
    (ARRAY['prospect','active','active','active','churned'])[1+floor(random()*5)::int],
    now() - (random()*interval '365 days')
  FROM generate_series(1,(SELECT n_customers FROM p)) g
  RETURNING id
)
INSERT INTO finallab.orders (customer_id, created_at, amount_cents, state)
SELECT
  c.id,
  now() - (random()*interval '120 days'),
  (500 + (random()*50000))::int,
  (ARRAY['new','paid','paid','shipped','cancelled'])[1+floor(random()*5)::int]
FROM ins_c c,
     generate_series(1, 2 + (random()*4)::int);  -- 2..6 orders per customer

ANALYZE VERBOSE finallab.customers;
ANALYZE VERBOSE finallab.orders;

-- ==============================
-- 2) Baseline Queries (suboptimal patterns)
-- ==============================

-- B1) Non-sargable email search
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, email
FROM finallab.customers
WHERE lower(email) = 'user12345@example.com';

-- B2) Non-sargable date_trunc filter
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM finallab.orders
WHERE date_trunc('day', created_at) = date_trunc('day', now() - interval '7 days');

-- B3) Join without supporting index on orders.customer_id
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.customer_id, sum(o.amount_cents) AS total
FROM finallab.orders o
JOIN finallab.customers c ON c.id = o.customer_id
WHERE c.status = 'active'
  AND o.created_at >= now() - interval '30 days'
GROUP BY o.customer_id
ORDER BY total DESC
LIMIT 20;

-- ==============================
-- 3) Indexes & Statistics
-- ==============================

-- I1) Functional index for case-insensitive email lookup
CREATE INDEX idx_customers_lower_email ON finallab.customers ((lower(email)));

-- I2) BRIN index for time-series queries on orders.created_at
CREATE INDEX idx_orders_created_at_brin ON finallab.orders USING BRIN (created_at);

-- I3) Composite index with INCLUDE for join + aggregation
CREATE INDEX idx_orders_customer_created_at_incl
  ON finallab.orders (customer_id, created_at) INCLUDE (amount_cents);

-- I4) Extended statistics for better estimates on correlated columns
CREATE STATISTICS st_customers_dep (dependencies) ON status, country FROM finallab.customers;
CREATE STATISTICS st_orders_dep (dependencies) ON state, created_at FROM finallab.orders;

ANALYZE finallab.customers;
ANALYZE finallab.orders;

-- ==============================
-- 4) Rewritten Queries (sargable + indexes)
-- ==============================

-- R1) Email lookup (uses functional index)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, email
FROM finallab.customers
WHERE lower(email) = lower('user12345@example.com');

-- R2) Date range rewritten as half-open interval (uses BRIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM finallab.orders
WHERE created_at >= date_trunc('day', now() - interval '7 days')
  AND created_at <  date_trunc('day', now() - interval '6 days');

-- R3) Join with indexes available
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.customer_id, sum(o.amount_cents) AS total
FROM finallab.orders o
JOIN finallab.customers c ON c.id = o.customer_id
WHERE c.status = 'active'
  AND o.created_at >= now() - interval '30 days'
GROUP BY o.customer_id
ORDER BY total DESC
LIMIT 20;

-- ==============================
-- 5) Optional: pg_stat_statements
-- ==============================
-- SELECT queryid, calls, mean_exec_time, rows
-- FROM pg_stat_statements
-- WHERE query ILIKE '%finallab.%'
-- ORDER BY mean_exec_time DESC
-- LIMIT 10;

-- ==============================
-- 6) Cleanup (optional)
-- ==============================
-- DROP SCHEMA finallab CASCADE;
