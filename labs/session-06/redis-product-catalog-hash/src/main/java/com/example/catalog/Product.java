package com.example.catalog;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.index.Indexed;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@RedisHash("product")
public class Product {
    @Id
    @NotBlank
    private String id;
    @NotBlank
    private String name;
    @Indexed
    private String category;
    private List<String> tags;
    @NotNull @Positive
    private BigDecimal price;
    @Indexed
    private Instant updatedAt = Instant.now();

    public Product() {}

    public Product(String id, String name, String category, List<String> tags, BigDecimal price) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.tags = tags;
        this.price = price;
        this.updatedAt = Instant.now();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
