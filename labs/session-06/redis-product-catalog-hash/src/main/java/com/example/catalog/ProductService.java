package com.example.catalog;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

import java.math.BigDecimal;

@Service
public class ProductService {

    private static final String VIEWS_ZSET = "products:views";

    private final ProductRepository productRepository;
    private final RedisTemplate<String, Product> productRedis;
    private final StringRedisTemplate stringRedis;

    public ProductService(ProductRepository productRepository,
                          RedisTemplate<String, Product> productRedis,
                          StringRedisTemplate stringRedis) {
        this.productRepository = productRepository;
        this.productRedis = productRedis;
        this.stringRedis = stringRedis;
    }

    /** Save a product with optional TTL (seconds). */
    public void save(Product p, Long ttlSeconds) {
        p.setUpdatedAt(Instant.now());
        if (ttlSeconds != null && ttlSeconds > 0) {
            // Para TTL personalizado, aún usamos RedisTemplate
            productRedis.opsForValue().set("product:" + p.getId(), p, Duration.ofSeconds(ttlSeconds));
        } else {
            // Para persistencia normal, usamos el repositorio
            productRepository.save(p);
        }
    }

    /** Get product by id and increment its view score in a sorted set. */
    public Optional<Product> getAndTrackView(String id) {
        Optional<Product> product = productRepository.findById(id);
        if (product.isPresent()) {
            stringRedis.opsForZSet().incrementScore(VIEWS_ZSET, id, 1.0);
        }
        return product;
    }

    /** Remove a product. */
    public boolean delete(String id) {
        stringRedis.opsForZSet().remove(VIEWS_ZSET, id);
        productRepository.deleteById(id);
        return true;
    }

    /** Get top-N most viewed products (by IDs, then hydrate). */
    public List<Product> topViewed(int limit) {
        Set<String> ids = stringRedis.opsForZSet()
                .reverseRange(VIEWS_ZSET, 0, Math.max(0, limit - 1));
        if (ids == null || ids.isEmpty()) return List.of();
        
        // Usar el repositorio para obtener los productos
        List<Product> result = new ArrayList<>();
        for (String id : ids) {
            Optional<Product> product = productRepository.findById(id);
            if (product.isPresent()) {
                result.add(product.get());
            }
        }
        return result;
    }

    /** Get raw view score for an ID (for debugging/UI). */
    public Double getViewScore(String id) {
        return stringRedis.opsForZSet().score(VIEWS_ZSET, id);
    }

    // Métodos del repositorio (soportados)
    public List<Product> findByCategory(String category) {
        return productRepository.findByCategory(category);
    }

    // Métodos personalizados para funcionalidades no soportadas por Spring Data Redis
    
    public List<Product> findByUpdatedAtAfter(Instant after) {
        // Implementación personalizada usando stream
        return getAllProducts().stream()
                .filter(product -> product.getUpdatedAt() != null &&
                        product.getUpdatedAt().isAfter(after))
                .collect(Collectors.toList());
    }

    public List<Product> findByUpdatedAtBetween(Instant start, Instant end) {
        // Implementación personalizada usando stream
        return getAllProducts().stream()
                .filter(product -> product.getUpdatedAt() != null &&
                        product.getUpdatedAt().isAfter(start) &&
                        product.getUpdatedAt().isBefore(end))
                .collect(Collectors.toList());
    }

    public List<Product> findByPriceBetween(BigDecimal minPrice, BigDecimal maxPrice) {
        // Implementación personalizada usando stream
        return getAllProducts().stream()
                .filter(product -> product.getPrice() != null &&
                        product.getPrice().compareTo(minPrice) >= 0 &&
                        product.getPrice().compareTo(maxPrice) <= 0)
                .collect(Collectors.toList());
    }

    public List<Product> findByPriceLessThan(BigDecimal price) {
        // Implementación personalizada usando stream
        return getAllProducts().stream()
                .filter(product -> product.getPrice() != null &&
                        product.getPrice().compareTo(price) < 0)
                .collect(Collectors.toList());
    }

    public List<Product> findByPriceGreaterThan(BigDecimal price) {
        // Implementación personalizada usando stream
        return getAllProducts().stream()
                .filter(product -> product.getPrice() != null &&
                        product.getPrice().compareTo(price) > 0)
                .collect(Collectors.toList());
    }

    public List<Product> findByTagsContaining(String tag) {
        // Implementación personalizada usando stream
        return getAllProducts().stream()
                .filter(product -> product.getTags() != null &&
                        product.getTags().contains(tag))
                .collect(Collectors.toList());
    }

    public List<Product> findRecentlyAdded(int daysAgo) {
        Instant cutoff = Instant.now().minusSeconds(daysAgo * 24 * 60 * 60L);
        // Implementación personalizada usando stream
        return getAllProducts().stream()
                .filter(product -> product.getUpdatedAt() != null &&
                        product.getUpdatedAt().isAfter(cutoff))
                .sorted((p1, p2) -> {
                    if (p1.getUpdatedAt() == null) return 1;
                    if (p2.getUpdatedAt() == null) return -1;
                    return p2.getUpdatedAt().compareTo(p1.getUpdatedAt());
                })
                .collect(Collectors.toList());
    }

    public List<Product> findByCategoryAndPriceRange(String category, BigDecimal minPrice, BigDecimal maxPrice) {
        // Implementación personalizada combinando categoría y rango de precio
        return getAllProducts().stream()
                .filter(product -> category.equals(product.getCategory()) &&
                        product.getPrice() != null &&
                        product.getPrice().compareTo(minPrice) >= 0 &&
                        product.getPrice().compareTo(maxPrice) <= 0)
                .collect(Collectors.toList());
    }

    // Método auxiliar para obtener todos los productos
    private List<Product> getAllProducts() {
        List<Product> allProducts = new ArrayList<>();
        productRepository.findAll().forEach(allProducts::add);
        return allProducts;
    }
}
