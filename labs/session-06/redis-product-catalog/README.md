# Redis Product Catalog (Spring Boot)

Features:
- Store product details in Redis using **RedisTemplate** (JSON serializer)
- Retrieve product by ID
- **TTL per product** (expiry) on upsert
- Track **most viewed** products in a **sorted set** (`ZSET`)

## Requirements
- Java 17+, Maven 3.9+
- Redis (local or remote). Quick start:
```bash
docker run -p 6379:6379 --name redis -d redis:7
```

## Run
```bash
export REDIS_HOST=localhost REDIS_PORT=6379
mvn spring-boot:run
```

## API
- **Upsert with optional TTL**
  ```bash
  curl -X POST "http://localhost:8080/api/products/p1?ttlSeconds=120" \
    -H "Content-Type: application/json" \
    -d '{ "name": "USB-C Hub", "category": "accessories", "tags":["usb","hub"], "price": 29.99 }'
  ```
- **Get by ID** (also increments view count in ZSET)
  ```bash
  curl "http://localhost:8080/api/products/p1"
  ```
- **Get top-N most viewed**
  ```bash
  curl "http://localhost:8080/api/products/top?limit=5"
  ```
- **Delete**
  ```bash
  curl -X DELETE "http://localhost:8080/api/products/p1"
  ```
- **Get view count for a product**
  ```bash
  curl "http://localhost:8080/api/products/p1/views"
  ```

## Notes
- Keys are `product:<id>`; values are JSON via `GenericJackson2JsonRedisSerializer`.
- Views sorted-set key: `products:views` with member=`<id>`, score=`view count`.
- If a product expires (TTL), it will be missing from the top list hydration.
