# Session 6: Redis and Spring Boot

## Duration: 3 hours

---

## 🧠 Objectives

- Understand what Redis is and where it fits in system architecture.
- Configure Redis with Spring Boot applications.
- Use RedisTemplate for manual Redis operations.
- Explore Redis repositories for structured access.
- Practice connecting Spring Boot with Redis in a real app.

---

## 1. What is Redis?

Redis is an in-memory key-value store often used for:

- Caching
- Real-time analytics
- Session management
- Pub/Sub messaging
- Distributed locks

**Features:**

- Extremely fast
- Supports data structures: strings, hashes, lists, sets, sorted sets
- Persistence via AOF and RDB

---

## 2. When to Use Redis in Spring Apps

| Use Case            | Redis Role                              |
|---------------------|------------------------------------------|
| Caching             | Reduce DB load for hot data             |
| Session Storage     | Scalable, distributed session store     |
| Rate Limiting       | Counter with TTL                        |
| Pub/Sub Messaging   | Channel-based communication             |
| Leader Election     | Using distributed locks or TTLs         |

---

## 3. Adding Redis to Spring Boot

### Dependencies (Maven)

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

### Configuration (application.yml)

```yaml
spring:
  redis:
    host: localhost
    port: 6379
```

Use a local Redis container:

```bash
docker run -d -p 6379:6379 redis
```

---

## 4. Using RedisTemplate

```java
@Service
public class VisitService {

    private final RedisTemplate<String, Integer> redisTemplate;

    public VisitService(RedisTemplate<String, Integer> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public void incrementVisit(String page) {
        redisTemplate.opsForValue().increment("visits:" + page);
    }

    public int getVisits(String page) {
        Integer count = redisTemplate.opsForValue().get("visits:" + page);
        return count != null ? count : 0;
    }
}
```

---

## 5. Redis Repositories

Define entities with `@RedisHash`:

```java
@RedisHash("session")
public class Session {
    @Id
    private String id;
    private String user;
    private Instant lastAccess;
}
```

Create a repository:

```java
public interface SessionRepository extends CrudRepository<Session, String> {
    List<Session> findByUser(String user);
}
```

Spring Boot will handle serialization and access logic.

---

## 6. Practice: Build Redis Integration

### Task

Create a **page view tracker**:

- Endpoint: `GET /visit/{page}`
- On call: increment visit counter in Redis
- Return current visit count

### Example Controller

```java
@RestController
public class VisitController {

    private final VisitService visitService;

    public VisitController(VisitService visitService) {
        this.visitService = visitService;
    }

    @GetMapping("/visit/{page}")
    public ResponseEntity<Integer> visit(@PathVariable String page) {
        visitService.incrementVisit(page);
        return ResponseEntity.ok(visitService.getVisits(page));
    }
}
```

---

## ✅ Summary

In this session, you:

- Explored Redis and its role in backend applications
- Integrated Redis with Spring Boot using `RedisTemplate`
- Defined structured access via Redis repositories
- Built a simple visit counter to demonstrate Redis usage

Next session: **Caching Strategies with Redis**
