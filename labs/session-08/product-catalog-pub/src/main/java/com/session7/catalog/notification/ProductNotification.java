package com.session7.catalog.notification;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * DTO para las notificaciones de productos
 */
public class ProductNotification {
    
    @JsonProperty("event")
    private String event;
    
    @JsonProperty("productId")
    private String productId;
    
    @JsonProperty("id")
    private Long id;
    
    @JsonProperty("name")
    private String name;
    
    @JsonProperty("category")
    private String category;
    
    @JsonProperty("price")
    private BigDecimal price;
    
    @JsonProperty("viewCount")
    private Long viewCount;
    
    @JsonProperty("timestamp")
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant timestamp;
    
    // Constructor por defecto para Jackson
    public ProductNotification() {}
    
    public ProductNotification(String event, String productId, Long id, String name, 
                             String category, BigDecimal price, Long viewCount) {
        this.event = event;
        this.productId = productId;
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.viewCount = viewCount;
        this.timestamp = Instant.now();
    }
    
    // Getters y Setters
    public String getEvent() { return event; }
    public void setEvent(String event) { this.event = event; }
    
    public String getProductId() { return productId; }
    public void setProductId(String productId) { this.productId = productId; }
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    
    public Long getViewCount() { return viewCount; }
    public void setViewCount(Long viewCount) { this.viewCount = viewCount; }
    
    public Instant getTimestamp() { return timestamp; }
    public void setTimestamp(Instant timestamp) { this.timestamp = timestamp; }
    
    @Override
    public String toString() {
        return "ProductNotification{" +
                "event='" + event + '\'' +
                ", productId='" + productId + '\'' +
                ", id=" + id +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", price=" + price +
                ", viewCount=" + viewCount +
                ", timestamp=" + timestamp +
                '}';
    }
}
