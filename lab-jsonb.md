# Exercise: JSONB in Java (Insert, Query, Index, Update)

**Time:** 45 min • **Goal:** Insert JSONB from Java, query via JSONB operators, and index for speed.

## 0) Setup
```sql
\c myapp
CREATE SCHEMA IF NOT EXISTS app;
CREATE TABLE IF NOT EXISTS app.events (
  id BIGSERIAL PRIMARY KEY,
  kind TEXT NOT NULL,
  payload JSONB NOT NULL,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_events_payload_gin ON app.events USING gin (payload jsonb_path_ops);
```

## 1) Insert JSONB from Java (JDBC)
```java
PGobject jb = new PGobject();
jb.setType("jsonb");
jb.setValue("{\"sku\":\"A-1\",\"qty\":2,\"tags\":[\"promo\",\"blue\"]}");

try (PreparedStatement ps =
     con.prepareStatement("INSERT INTO app.events(kind,payload) VALUES(?,?)")) {
  ps.setString(1, "order_created");
  ps.setObject(2, jb);
  ps.executeUpdate();
}
```

## 2) Query with JSONB operators
```sql
-- Containment
SELECT id FROM app.events WHERE payload @> '{"sku":"A-1"}';

-- Field access
SELECT payload->>'sku' AS sku FROM app.events WHERE kind = 'order_created';

-- Array contains
SELECT id FROM app.events WHERE payload->'tags' ? 'promo';

-- Path (PG 12+)
SELECT id FROM app.events WHERE payload @? '$.qty ? (@ > 1)';
```
Measure with and without the GIN index.

## 3) Update JSONB
```sql
-- Set a field
UPDATE app.events SET payload = jsonb_set(payload, '{status}', '"shipped"', true)
WHERE id = 1;

-- Remove a field
UPDATE app.events SET payload = payload - 'tags' WHERE id = 1;
```

## 4) Bonus: Partial indexes
```sql
CREATE INDEX IF NOT EXISTS idx_events_kind ON app.events(kind);
CREATE INDEX IF NOT EXISTS idx_events_payload_sku ON app.events ((payload->>'sku'));
```

## Deliverables
- Java snippet showing JSONB insert and a select by `payload @> ...`.
- Think about 2–3 sentences: when to use columns vs JSONB; how to combine both.
