package com.example.catalog;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ProductService {

    private static final String KEY_PREFIX = "product:";
    private static final String VIEWS_ZSET = "products:views";

    private final RedisTemplate<String, Product> productRedis;
    private final StringRedisTemplate stringRedis;

    public ProductService(RedisTemplate<String, Product> productRedis,
                          StringRedisTemplate stringRedis) {
        this.productRedis = productRedis;
        this.stringRedis = stringRedis;
    }

    private String key(String id) { return KEY_PREFIX + id; }

    /** Save a product with optional TTL (seconds). */
    public void save(Product p, Long ttlSeconds) {
        p.setUpdatedAt(java.time.Instant.now());
        if (ttlSeconds != null && ttlSeconds > 0) {
            productRedis.opsForValue().set(key(p.getId()), p, Duration.ofSeconds(ttlSeconds));
        } else {
            productRedis.opsForValue().set(key(p.getId()), p);
        }
    }

    /** Get product by id and increment its view score in a sorted set. */
    public Optional<Product> getAndTrackView(String id) {
        Product p = productRedis.opsForValue().get(key(id));
        if (p != null) {
            stringRedis.opsForZSet().incrementScore(VIEWS_ZSET, id, 1.0);
        }
        return Optional.ofNullable(p);
    }

    /** Remove a product. */
    public boolean delete(String id) {
        Boolean deleted = productRedis.delete(key(id));
        stringRedis.opsForZSet().remove(VIEWS_ZSET, id);
        return Boolean.TRUE.equals(deleted);
    }

    /** Get top-N most viewed products (by IDs, then hydrate). */
    public List<Product> topViewed(int limit) {
        Set<String> ids = stringRedis.opsForZSet()
                .reverseRange(VIEWS_ZSET, 0, Math.max(0, limit - 1));
        if (ids == null || ids.isEmpty()) return List.of();
        // fetch in batch
        List<Product> result = productRedis.opsForValue()
                .multiGet(ids.stream().map(this::key).collect(Collectors.toList()));
        if (result == null) return List.of();
        // Preserve the sorted order by ids set; filter out nulls (expired TTL)
        Map<String, Product> byKey = result.stream()
                .filter(Objects::nonNull)
                .collect(Collectors.toMap(p -> key(p.getId()), p -> p));
        List<Product> ordered = new ArrayList<>();
        for (String id : ids) {
            Product p = byKey.get(key(id));
            if (p != null) ordered.add(p);
        }
        return ordered;
    }

    /** Get raw view score for an ID (for debugging/UI). */
    public Double getViewScore(String id) {
        return stringRedis.opsForZSet().score(VIEWS_ZSET, id);
    }
}
