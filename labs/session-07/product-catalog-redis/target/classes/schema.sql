-- Crear la base de datos (ejecutar manualmente en PostgreSQL)
-- CREATE DATABASE product_catalog;

-- Crear tabla de productos
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    product_id VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    price DECIMAL(10,2) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    view_count BIGINT DEFAULT 0
);

-- Crear tabla para tags de productos
CREATE TABLE IF NOT EXISTS product_tags (
    product_id BIGINT NOT NULL,
    tag VARCHAR(255),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_products_product_id ON products(product_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_view_count ON products(view_count DESC);
CREATE INDEX IF NOT EXISTS idx_products_updated_at ON products(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_tags_product_id ON product_tags(product_id);

-- Insertar algunos productos de ejemplo
INSERT INTO products (product_id, name, category, price, view_count) VALUES
    ('PROD001', 'Laptop Gaming', 'Electronics', 1299.99, 0),
    ('PROD002', 'Smartphone', 'Electronics', 699.99, 0),
    ('PROD003', 'Running Shoes', 'Sports', 89.99, 0),
    ('PROD004', 'Coffee Maker', 'Home', 149.99, 0),
    ('PROD005', 'Yoga Mat', 'Sports', 29.99, 0)
ON CONFLICT (product_id) DO NOTHING;

-- Insertar tags para los productos
INSERT INTO product_tags (product_id, tag) VALUES
    ((SELECT id FROM products WHERE product_id = 'PROD001'), 'gaming'),
    ((SELECT id FROM products WHERE product_id = 'PROD001'), 'laptop'),
    ((SELECT id FROM products WHERE product_id = 'PROD002'), 'mobile'),
    ((SELECT id FROM products WHERE product_id = 'PROD002'), 'smartphone'),
    ((SELECT id FROM products WHERE product_id = 'PROD003'), 'running'),
    ((SELECT id FROM products WHERE product_id = 'PROD003'), 'shoes'),
    ((SELECT id FROM products WHERE product_id = 'PROD004'), 'coffee'),
    ((SELECT id FROM products WHERE product_id = 'PROD004'), 'kitchen'),
    ((SELECT id FROM products WHERE product_id = 'PROD005'), 'yoga'),
    ((SELECT id FROM products WHERE product_id = 'PROD005'), 'fitness')
ON CONFLICT DO NOTHING;
