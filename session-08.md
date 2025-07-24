# Session 8: Advanced Redis Usage

## Duration: 3 hours

---

## 🧠 Objectives

- Learn advanced Redis features for messaging and synchronization.
- Implement Pub/Sub messaging with Redis in Spring Boot.
- Use Redis for distributed locking.
- Manage user sessions with Redis.
- Understand Redis clustering and scaling considerations.

---

## 1. Pub/Sub Messaging Pattern

Redis supports message broadcasting using **channels**.

### Use cases:

- Event propagation
- Chat messaging
- Real-time notifications

### Spring Integration

**Publisher:**

```java
@Autowired
private RedisTemplate<String, String> redisTemplate;

public void publish(String topic, String message) {
    redisTemplate.convertAndSend(topic, message);
}
```

**Subscriber:**

```java
@Component
public class MessageSubscriber implements MessageListener {
    public void onMessage(Message message, byte[] pattern) {
        System.out.println("Received: " + message.toString());
    }
}
```

**Configuration:**

```java
@Bean
public MessageListenerAdapter listenerAdapter() {
    return new MessageListenerAdapter(new MessageSubscriber());
}

@Bean
public RedisMessageListenerContainer container(...) {
    RedisMessageListenerContainer container = new RedisMessageListenerContainer();
    container.addMessageListener(listenerAdapter(), new PatternTopic("my-channel"));
    return container;
}
```

---

## 2. Distributed Locking Pattern

Redis can be used to manage distributed locks:

```java
Boolean acquired = redisTemplate.opsForValue()
    .setIfAbsent("lock:resource", "1", Duration.ofSeconds(10));

if (Boolean.TRUE.equals(acquired)) {
    // Do work
    redisTemplate.delete("lock:resource");
}
```

Use libraries like **Redisson** or **Spring Integration Redis** for more robust implementations.

---

## 3. Session Management with Redis

Store session state in Redis to share across services.

### Spring Boot Setup

```yaml
spring:
  session:
    store-type: redis
```

Add dependency:

```xml
<dependency>
  <groupId>org.springframework.session</groupId>
  <artifactId>spring-session-data-redis</artifactId>
</dependency>
```

Benefits:

- Centralized session store
- Horizontal scalability
- Reduced memory pressure on app instances

---

## 4. Redis Cluster and Scaling

When using Redis at scale:

- Use **Redis Cluster** for data sharding
- Use **Sentinel** for high availability
- Monitor via tools like RedisInsight

**Scaling approaches:**

| Strategy            | Description                        |
|---------------------|------------------------------------|
| Sharding (Cluster)  | Distribute keys across nodes       |
| Replication         | Add read replicas                  |
| Partitioning        | Manually split by key namespaces   |
| Eviction tuning     | Control memory pressure            |

---

## 5. Practice: Notification Broadcasting

### Task:

- Create a `/send/{msg}` endpoint to publish messages
- Create a Redis subscriber that logs received messages

### Sample:

```java
@RestController
public class NotificationController {

    private final RedisTemplate<String, String> redisTemplate;

    public NotificationController(RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    @GetMapping("/send/{msg}")
    public void send(@PathVariable String msg) {
        redisTemplate.convertAndSend("alerts", msg);
    }
}
```

---

## ✅ Summary

In this session, you:

- Implemented Pub/Sub messaging with Redis and Spring Boot
- Created distributed locks with Redis keys
- Centralized HTTP session storage in Redis
- Explored Redis scaling strategies with clustering and sentinel

🎓 Congratulations — you’ve completed the course!

---

## 🏁 Course Wrap-Up

You now have:

- A solid foundation in PostgreSQL architecture and tuning
- Skills to design normalized, scalable schemas for microservices
- Knowledge of query analysis and transactional workflows
- Integration patterns using Redis for caching, locking, messaging, and sessions
