# 🚀 Exercise 2: Implement Cache Aside and Write-Through on Product Catalog

**Objective:** Gain hands-on experience with manual cache management and custom key generation using Redis.  
**Time allocation:** ⏱ 1 hour 30 minutes  

---

## 📌 Tasks

### 1. Add **Cache Aside** and **Write-Through** strategies to the product catalog
- Configure `RedisTemplate` (refer to **Session 6 projects**). Remember to add pom dependencies
- Implement caching logic for `Product`.

---

## 🗂 Cache-Aside Pattern (with TTL = 1 hour)

```java
String cacheKey = "product:" + id;

// Try to get from cache first
Product product = valueOps.get(cacheKey);

if (product != null) {
    System.out.println("Cache HIT for product: " + id);
    return product;
}

// If not in cache, get from database
System.out.println("Cache MISS for product: " + id);
product = productRepository.findById(id)
        .orElseThrow(() -> new ProductNotFoundException(id));

// Store in cache with TTL
valueOps.set(cacheKey, product, 1, TimeUnit.HOURS);
```

---

## 📝 Write-Through Pattern

```java
// First save to the database to get generated ID if new
Product savedProduct = productRepository.save(product);                 

// Then update the cache        
String cacheKey = "product:" + savedProduct.getId();        
redisTemplate.getValueOps().set(cacheKey, savedProduct, 1, TimeUnit.HOURS);
```

---

## 🔑 Custom Keys for Queries

### Example: Cache `topViewedByCategory` or `searchProducts`

```java
@Cacheable(value = "products", 
          keyGenerator = "productKeyGenerator")
public List findProductsByFilters(ProductFilter filters) {
    return productRepository.findProductsByFilters(filters);
}
```

---

### Creating a Custom Key Generator

```java
@Component("productKeyGenerator")
public class ProductKeyGenerator implements KeyGenerator {
    
    @Override
    public Object generate(Object target, 
                          Method method,
                          Object... params) {
        ProductFilter filters = (ProductFilter) params[0];
        return "products_" + 
               filters.getCategory() + "_" +
               filters.getMinPrice() + "_" +
               filters.getMaxPrice();
    }
}
```

---

## 📊 (Optional) Metrics Service for Cache Hits & Misses

```java
@Service
public class CacheMetricsService {
 private final RedisTemplate redisTemplate;
 private final Counter cacheHits;
 private final Counter cacheMisses;
 private final Timer cacheLatency;
 
 public CacheMetricsService(RedisTemplate redisTemplate,
 MeterRegistry registry) {
   this.redisTemplate = redisTemplate;
   this.cacheHits = registry.counter("cache.hits");
   this.cacheMisses = registry.counter("cache.misses");
   this.cacheLatency = registry.timer("cache.latency");
 }
 
 public void recordHit(String cacheRegion) {
   cacheHits.increment();
   redisTemplate.opsForValue()
       .increment("metrics:cache:" + cacheRegion + ":hits");
 }
 
 public void recordMiss(String cacheRegion) {
   cacheMisses.increment();
   redisTemplate.opsForValue()
       .increment("metrics:cache:" + cacheRegion + ":misses");
 }
 
 public Timer.Sample startTimer() {
   return Timer.start();
 }
 
 public void stopTimer(Timer.Sample sample, boolean isHit) {
   sample.stop(cacheLatency.withTag("result", isHit ? "hit" : "miss"));
 }
 
 public Map getCacheStats(String cacheRegion) {
   String hitsKey = "metrics:cache:" + cacheRegion + ":hits";
   String missesKey = "metrics:cache:" + cacheRegion + ":misses";
 
   Map stats = new HashMap<>();
   stats.put("hits", Optional.ofNullable(redisTemplate.opsForValue().get(hitsKey))
     .map(Long::parseLong).orElse(0L));
   stats.put("misses", Optional.ofNullable(redisTemplate.opsForValue().get(missesKey))
     .map(Long::parseLong).orElse(0L));
 
   long total = (long) stats.get("hits") + (long) stats.get("misses");
   stats.put("hitRate", total > 0 ? ((long) stats.get("hits") * 100 / total) : 0);
 
   return stats;
 }
}
```

---

## 🎯 Bonus Challenge
Implement a **custom Redis serializer** that compresses large product descriptions before storing them in the cache.  

---

✅ With this exercise you’ll practice:  
- Manual **cache-aside & write-through** strategies.  
- **Custom key generation** for queries.  
- (Optional) **Metrics tracking** for cache performance.  
