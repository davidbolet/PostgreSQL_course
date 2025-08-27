package com.example.catalog;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public class Product {
    @NotBlank
    private String id;
    @NotBlank
    private String name;
    private String category;
    private List<String> tags;
    @NotNull @Positive
    private BigDecimal price;
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
