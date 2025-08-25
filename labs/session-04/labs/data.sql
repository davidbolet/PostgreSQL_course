SET search_path TO qa, public;

INSERT INTO customer(email, country, status, created_at)
SELECT 'user'||g||'@example.com',
       (ARRAY['US','ES','FR','DE','GB'])[1 + (g%5)],
       (ARRAY['active','active','active','inactive','banned'])[1 + (g%5)],
       now() - (g || ' days')::interval
FROM generate_series(1, 20000) g;

INSERT INTO orders(customer_id, created_at, status, total_cents)
SELECT (1 + (random()*19999)::int),
       now() - (random()*365 || ' days')::interval,
       (ARRAY['draft','confirmed','shipped','cancelled'])[1 + (random()*3)::int],
       (100 + (random()*50000))::int
FROM generate_series(1, 80000);

INSERT INTO order_items(order_id, product_id, qty, price_cents)
SELECT (1 + (random()*79999)::int),
       (1 + (random()*2000)::int),
       (1 + (random()*5)::int),
       (100 + (random()*20000))::int
FROM generate_series(1, 200000);
