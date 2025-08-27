# Redis Template Demo (Spring Boot + Maven)

A minimal project showing how to configure **RedisTemplate** and store/retrieve JSON objects in Redis.

## Prereqs
- Java 17+
- Maven 3.9+
- Redis running locally (or set env vars)

Quick Redis via Docker:
```bash
docker run -p 6379:6379 --name redis -d redis:7
```

## Run
```bash
# Optional env overrides
export REDIS_HOST=localhost
export REDIS_PORT=6379
mvn spring-boot:run
```

## Try it
Create/update a session (with a TTL of 60s):
```bash
curl -X POST "http://localhost:8080/api/sessions/abc123?username=ada&role=USER&role=ADMIN&ttlSeconds=60"
```

Fetch it:
```bash
curl "http://localhost:8080/api/sessions/abc123"
```

Delete it:
```bash
curl -X DELETE "http://localhost:8080/api/sessions/abc123"
```

## Notes
- Keys are `session:<id>`
- Keys use **String** serializer; values are stored as **JSON** using `GenericJackson2JsonRedisSerializer`
- You can switch to `StringRedisTemplate` if you only need string values
