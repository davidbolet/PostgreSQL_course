-- JSONB variable attributes lab SQL (corrected JSONPath)

CREATE SCHEMA IF NOT EXISTS catalog;

CREATE TABLE IF NOT EXISTS catalog.products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  attrs JSONB NOT NULL
);

INSERT INTO catalog.products (name, category, price, attrs) VALUES
('ThinkPro 14', 'laptop', 1299.00, '{"cpu":"i7","ram_gb":16,"storage_ssd_gb":512,"gpu":"RTX 4050"}'),
('UltraLite 13', 'laptop', 999.00, '{"cpu":"i5","ram_gb":8,"storage_ssd_gb":256}'),
('Photon X', 'phone', 799.00, '{"camera_mp":64,"dual_sim":true,"battery_mah":4800}'),
('Photon Mini', 'phone', 499.00, '{"camera_mp":12,"dual_sim":false,"battery_mah":3000}'),
('Trail Runner', 'shoe', 149.00, '{"size_eu":42,"material":"leather","color":"brown"}'),
('City Sneak', 'shoe', 89.00, '{"size_eu":41,"material":"canvas","color":"white"}');

-- Correct JSONPath predicate
SELECT id, name
FROM catalog.products
WHERE category = 'laptop'
  AND attrs @? '$.ram_gb ? (@ >= 32)';

-- Fallback (works on all versions):
SELECT id, name
FROM catalog.products
WHERE category = 'laptop' AND (attrs->>'ram_gb')::int >= 32;
