package com.example.catalog;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.index.IndexConfiguration;
import org.springframework.data.redis.core.index.IndexDefinition;
import org.springframework.data.redis.core.index.SimpleIndexDefinition;
import org.springframework.data.redis.core.mapping.RedisMappingContext;

@Configuration
public class RedisIndexConfig {

    @Bean
    public IndexConfiguration indexConfiguration(RedisMappingContext mappingContext) {
        IndexConfiguration config = new IndexConfiguration();
        
        // Configurar índices para el modelo Product
        config.addIndexDefinition(new SimpleIndexDefinition("product", "category"));
        config.addIndexDefinition(new SimpleIndexDefinition("product", "updatedAt"));
        config.addIndexDefinition(new SimpleIndexDefinition("product", "price"));
        
        return config;
    }
}
