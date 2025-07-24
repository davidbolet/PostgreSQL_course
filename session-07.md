# Session 7: Caching Strategies with Redis

## Duration: 3 hours

---

## 🧠 Objectives

- Understand caching concepts and design patterns.
- Configure Spring Boot caching with Redis as a backend.
- Apply common caching strategies: cache-aside, read-through, write-through, write-behind.
- Use TTL and eviction policies in Redis.
- Implement a cache layer for a real-world service.

---

## 1. Why Caching?

Caching helps to:

- Reduce database load
- Speed up response times
- Offload expensive computations
- Improve user experience

But it introduces challenges like:

- Stale data
- Eviction policies
- Cache invalidation

---

## 2. Enable Caching in Spring Boot

### Add to main class

```java
@SpringBootApplication
@EnableCaching
public class App { ... }
```

### Configuration (application.yml)

```yaml
spring:
  cache:
    type: redis
```

Spring Boot will use Redis automatically via `CacheManager`.

---

## 3. Basic Caching with Annotations

```java
@Cacheable("products")
public Product getProductById(Long id) {
    return repository.findById(id).orElseThrow();
}

@CacheEvict(value = "products", key = "#id")
public void deleteProduct(Long id) {
    repository.deleteById(id);
}

@CachePut(value = "products", key = "#product.id")
public Product updateProduct(Product product) {
    return repository.save(product);
}
```

---

## 4. Cache-Aside Pattern

- App checks cache first
- If not found, fetches from DB and stores in cache
- Most common pattern

**Pros:** easy to implement  
**Cons:** risk of stale data on DB update

---

## 5. Read-Through & Write-Through

**Read-Through:** Cache handles DB read internally  
**Write-Through:** Writes go through the cache, then to DB

- Used with frameworks like Spring Data Redis and custom `CacheWriter`

---

## 6. Write-Behind Pattern

- Data written to cache, and persisted to DB later via queue

**Use case:** High-write, eventual consistency allowed  
**Risk:** Data loss if Redis crashes before flush

---

## 7. TTL and Eviction

Set TTL:

```java
@Bean
public RedisCacheConfiguration cacheConfiguration() {
    return RedisCacheConfiguration.defaultCacheConfig()
        .entryTtl(Duration.ofMinutes(10));
}
```

Eviction policies supported by Redis:
- `volatile-lru`, `allkeys-lru`, `volatile-ttl`, `noeviction`

---

## 8. Practice: Product Catalog Caching

### Scenario

You're building a product catalog for an e-commerce site.

Tasks:

- Cache products by ID with TTL
- Invalidate cache when a product is deleted
- Use `@Cacheable`, `@CacheEvict`, and `@CachePut`

**Sample:**

```java
@Cacheable(value = "catalog", key = "#id")
public Product getProduct(Long id) {
    return productRepo.findById(id).orElseThrow();
}

@CacheEvict(value = "catalog", key = "#id")
public void deleteProduct(Long id) {
    productRepo.deleteById(id);
}
```

---

## ✅ Summary

In this session, you:

- Explored multiple caching strategies and their trade-offs
- Configured Redis as a Spring Boot cache backend
- Used annotations to apply cache behavior
- Implemented TTL and eviction for efficient memory use
- Built a caching layer for a product catalog

Next session: **Advanced Redis Usage**
