# Lab: JSONB for Variable Attributes (Hybrid Modeling)

**Goal:** model a product catalog where attributes vary by category using **JSONB**, then query and index it effectively in PostgreSQL.

## 0) Prerequisites
- psql connected as a role that can create schema/objects.
- PostgreSQL 13+ recommended (JSONPath `@?` requires PG12+).

## 1) Create schema and table
```sql
CREATE SCHEMA IF NOT EXISTS catalog;

CREATE TABLE catalog.products (
  id           BIGSERIAL PRIMARY KEY,
  name         TEXT        NOT NULL,
  category     TEXT        NOT NULL,            -- 'laptop' | 'phone' | 'shoe' | ...
  price        NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  attrs        JSONB       NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chk_attrs_is_object CHECK (jsonb_typeof(attrs) = 'object')
);
```

### (Optional) Light per-category validation
```sql
ALTER TABLE catalog.products
  ADD CONSTRAINT chk_attrs_required
  CHECK (
    CASE category
      WHEN 'laptop' THEN attrs ? 'cpu' AND attrs ? 'ram_gb'
      WHEN 'shoe'   THEN attrs ? 'size_eu' AND attrs ? 'material'
      ELSE TRUE
    END
  );
```

## 2) Insert sample data
```sql
INSERT INTO catalog.products (name, category, price, attrs) VALUES
('ThinkPro 14', 'laptop', 1299.00, '{"cpu":"i7","ram_gb":16,"storage_ssd_gb":512,"gpu":"RTX 4050"}'),
('UltraLite 13', 'laptop', 999.00, '{"cpu":"i5","ram_gb":8,"storage_ssd_gb":256}'),
('Photon X', 'phone', 799.00, '{"camera_mp":64,"dual_sim":true,"battery_mah":4800}'),
('Photon Mini', 'phone', 499.00, '{"camera_mp":12,"dual_sim":false,"battery_mah":3000}'),
('Trail Runner', 'shoe', 149.00, '{"size_eu":42,"material":"leather","color":"brown"}'),
('City Sneak', 'shoe', 89.00, '{"size_eu":41,"material":"canvas","color":"white"}');
```

## 3) Queries to try
- Laptops with >= 16 GB RAM
```sql
SELECT id, name FROM catalog.products
WHERE category = 'laptop' AND (attrs->>'ram_gb')::int >= 16;
```
- Shoes that are leather and size 42
```sql
SELECT id, name FROM catalog.products
WHERE category = 'shoe'
  AND attrs @> '{"material":"leather"}'
  AND (attrs->>'size_eu')::int = 42;
```
- Phones that have `dual_sim` key
```sql
SELECT id, name FROM catalog.products
WHERE category = 'phone' AND attrs ? 'dual_sim';
```
- JSONPath: laptops with RAM >= 32
```sql
SELECT id, name FROM catalog.products
WHERE category = 'laptop' AND attrs @? '$.?(@.ram_gb >= 32)';
```

## 4) Indexing
- GIN on attrs for containment/existence/JSONPath
```sql
CREATE INDEX idx_products_attrs_gin
  ON catalog.products USING gin (attrs jsonb_path_ops);
```
- Expression index for a hot numeric filter (typed) + partial
```sql
CREATE INDEX idx_products_shoe_size
  ON catalog.products ( ((attrs->>'size_eu')::int) )
  WHERE category = 'shoe';
```

### Compare plans
```sql
EXPLAIN ANALYZE
SELECT id, name FROM catalog.products
WHERE category = 'shoe'
  AND attrs @> '{"material":"leather"}'
  AND (attrs->>'size_eu')::int = 42;
```

## 5) Stretch goals (choose any)
- Add a **generated column** for `sku` extracted from `attrs` and index it.
- Create a partial index for `laptop` models by `ram_gb`.
- Write an UPDATE that uses `jsonb_set` to add a field `status="active"` to all products.
- Add a CHECK that `ram_gb` must be positive for `category='laptop'`.

## 6) Cleanup (optional)
```sql
DROP SCHEMA catalog CASCADE;
```
