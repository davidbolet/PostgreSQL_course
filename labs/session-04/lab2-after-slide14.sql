-- Lab SQL: Multi-Column & Partial Indexes (PostgreSQL)
-- This script sets up data, runs baseline measurements, creates indexes,
-- and runs measurements again.
-- Run in psql. You may copy/paste or:  \i lab-after-slide14.sql

-- ==============================
-- 0) Prerequisites (optional)
-- ==============================
-- If you want to verify extensions are present:
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- CREATE EXTENSION IF NOT EXISTS auto_explain;
-- \dx

-- Helpful for timing:
\timing on

-- ==============================
-- 1) Schema & Data Setup
-- ==============================
DROP SCHEMA IF EXISTS lab14 CASCADE;
CREATE SCHEMA lab14;
SET search_path TO lab14, public;

-- Tables
CREATE TABLE lab14.orders (
  id           BIGSERIAL PRIMARY KEY,
  tenant_id    INT         NOT NULL,
  status       TEXT        NOT NULL CHECK (status IN ('active','cancelled','shipped','pending')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  total_cents  INT         NOT NULL
);

CREATE TABLE lab14.order_items (
  id           BIGSERIAL PRIMARY KEY,
  order_id     BIGINT      NOT NULL REFERENCES lab14.orders(id) ON DELETE CASCADE,
  product_id   INT         NOT NULL,
  qty          INT         NOT NULL,
  price_cents  INT         NOT NULL
);

-- Seed data: ~200k orders, 1-4 items each (≈600k–900k items)
WITH params AS (
  SELECT 200000 AS n_orders, 50 AS n_tenants
),
ins_orders AS (
  INSERT INTO lab14.orders (tenant_id, status, created_at, total_cents)
  SELECT
    1 + (random() * (p.n_tenants-1))::int                                         AS tenant_id,
    (ARRAY['active','active','active','shipped','pending','cancelled'])[1+floor(random()*6)::int] AS status,
    now() - (random() * interval '90 days')                                       AS created_at,
    (1000 + (random()*90000))::int                                                AS total_cents
  FROM params p, generate_series(1, (SELECT n_orders FROM params)) g
  RETURNING id
)
INSERT INTO lab14.order_items (order_id, product_id, qty, price_cents)
SELECT
  o.id,
  1 + (random()*5000)::int AS product_id,
  1 + (random()*5)::int    AS qty,
  100 + (random()*5000)::int AS price_cents
FROM ins_orders o,
     generate_series(1, 1 + (random()*3)::int);  -- 1..4 items per order

ANALYZE VERBOSE lab14.orders;
ANALYZE VERBOSE lab14.order_items;

-- ==============================
-- 2) Baseline (before indexes)
-- ==============================
-- Optional: reset stats for clean measurement
-- SELECT pg_stat_statements_reset();

-- Q1) Tenant feed (recent first)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, tenant_id, status, created_at, total_cents
FROM lab14.orders
WHERE tenant_id = 7
ORDER BY created_at DESC
LIMIT 20;

-- Q2) Active orders by tenant in last 30 days
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, tenant_id, status, created_at
FROM lab14.orders
WHERE status = 'active'
  AND tenant_id = 7
  AND created_at >= now() - interval '30 days'
ORDER BY created_at DESC
LIMIT 50;

-- Q3) Join: Recent orders + items
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT oi.order_id, count(*) AS items
FROM lab14.order_items oi
JOIN lab14.orders o ON oi.order_id = o.id
WHERE o.created_at >= now() - interval '15 days'
GROUP BY oi.order_id
ORDER BY items DESC
LIMIT 20;

-- ==============================
-- 3) Indexes
-- ==============================

-- 3.1) Multi-column index for Q1
CREATE INDEX idx_orders_tenant_created_at_desc
  ON lab14.orders (tenant_id, created_at DESC);

-- 3.2) Partial composite index for Q2 (only 'active' rows)
CREATE INDEX idx_orders_active_tenant_created_at_desc
  ON lab14.orders (tenant_id, created_at DESC)
  WHERE status = 'active';

-- 3.3) Join helper index for Q3
CREATE INDEX idx_order_items_order_id
  ON lab14.order_items (order_id);

ANALYZE lab14.orders;
ANALYZE lab14.order_items;

-- ==============================
-- 4) Re-Measure (after indexes)
-- ==============================

-- Q1) Expect Index Scan / Index Only on orders
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, tenant_id, status, created_at, total_cents
FROM lab14.orders
WHERE tenant_id = 7
ORDER BY created_at DESC
LIMIT 20;

-- Q2) Expect usage of the partial index (status='active')
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, tenant_id, status, created_at
FROM lab14.orders
WHERE status = 'active'
  AND tenant_id = 7
  AND created_at >= now() - interval '30 days'
ORDER BY created_at DESC
LIMIT 50;

-- Q3) Expect Bitmap/Index probe on order_items(order_id)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT oi.order_id, count(*) AS items
FROM lab14.order_items oi
JOIN lab14.orders o ON oi.order_id = o.id
WHERE o.created_at >= now() - interval '15 days'
GROUP BY oi.order_id
ORDER BY items DESC
LIMIT 20;

-- ==============================
-- 5) Optional: pg_stat_statements view
-- ==============================
-- Run queries above a few times, then inspect:
-- SELECT queryid, calls, mean_exec_time, rows
-- FROM pg_stat_statements
-- WHERE query ILIKE '%lab14.%'
-- ORDER BY mean_exec_time DESC
-- LIMIT 10;

-- ==============================
-- 6) Cleanup (optional)
-- ==============================
-- DROP SCHEMA lab14 CASCADE;
