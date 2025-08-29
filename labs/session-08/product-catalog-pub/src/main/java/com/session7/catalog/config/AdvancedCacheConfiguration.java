package com.session7.catalog.config;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectMapper.DefaultTyping;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.jsontype.impl.LaissezFaireSubTypeValidator;

@Configuration
@EnableCaching
public class AdvancedCacheConfiguration {

    @Bean
    public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory, ObjectMapper httpObjectMapper) {
        // Create a specialized ObjectMapper for Redis with type information
        ObjectMapper redisMapper = httpObjectMapper.copy();
        redisMapper.activateDefaultTyping(
            LaissezFaireSubTypeValidator.instance,
            DefaultTyping.NON_FINAL,
            JsonTypeInfo.As.PROPERTY
        );
        
        // Use GenericJackson2JsonRedisSerializer with the specialized mapper
        GenericJackson2JsonRedisSerializer jsonSerializer = new GenericJackson2JsonRedisSerializer(redisMapper);
        
        // Default cache configuration
        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(10))
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(jsonSerializer));
                
        // Create different configurations for different caches
        Map<String, RedisCacheConfiguration> cacheConfigurations = new HashMap<>();
        
        // Products cache with 1 hour TTL
        cacheConfigurations.put("products", defaultConfig.entryTtl(Duration.ofHours(1)));
        
        // Top products cache with 30 minutes TTL
        cacheConfigurations.put("topProducts", defaultConfig.entryTtl(Duration.ofMinutes(30)));
        
        // Products by category cache with 2 hours TTL
        cacheConfigurations.put("productsByCategory", defaultConfig.entryTtl(Duration.ofHours(2)));
        
        // Search results cache with 15 minutes TTL
        cacheConfigurations.put("searchResults", defaultConfig.entryTtl(Duration.ofMinutes(15)));
        
        // All products cache with 1 hour TTL
        cacheConfigurations.put("allProducts", defaultConfig.entryTtl(Duration.ofHours(1)));
        
        // Categories cache with 1 day TTL
        cacheConfigurations.put("categories", defaultConfig.entryTtl(Duration.ofDays(1)));
        
        // User session cache with 30 minutes TTL
        cacheConfigurations.put("userSessions", defaultConfig
            .entryTtl(Duration.ofMinutes(30))
            .prefixCacheNameWith("session:"));
                
        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(defaultConfig)
            .withInitialCacheConfigurations(cacheConfigurations)
            .build();
    }
}