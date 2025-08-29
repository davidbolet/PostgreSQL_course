package com.session7.catalog.notification;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.session7.catalog.model.Product;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class NotificationPublisher implements NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationPublisher.class);
    
    // Canales de notificación
    public static final String PRODUCT_CREATED_CHANNEL = "product:created";
    public static final String PRODUCT_UPDATED_CHANNEL = "product:updated";
    public static final String PRODUCT_DELETED_CHANNEL = "product:deleted";
    public static final String PRODUCT_VIEWED_CHANNEL = "product:viewed";
    public static final String INVENTORY_ALERT_CHANNEL = "inventory:alerts";
    
    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;
    
    public NotificationPublisher(StringRedisTemplate redisTemplate, ObjectMapper objectMapper) {
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
    }
    
    /**
     * Publica notificación cuando se crea un producto
     */
    @Override
    public void publishProductCreated(Product product) {
        try {
            ProductNotification notification = new ProductNotification(
                "CREATED", 
                product.getProductId(), 
                product.getId(), 
                product.getName(), 
                product.getCategory(), 
                product.getPrice(), 
                product.getViewCount()
            );
            
            String message = objectMapper.writeValueAsString(notification);
            redisTemplate.convertAndSend(PRODUCT_CREATED_CHANNEL, message);
            
            logger.info("Published product created notification for product: {} (ID: {})", 
                       product.getProductId(), product.getId());
        } catch (JsonProcessingException e) {
            logger.error("Error serializing product created notification for product: {}", 
                        product.getProductId(), e);
        } catch (Exception e) {
            logger.error("Error publishing product created notification for product: {}", 
                        product.getProductId(), e);
        }
    }
    
    /**
     * Publica notificación cuando se actualiza un producto
     */
    @Override
    public void publishProductUpdated(Product product) {
        try {
            ProductNotification notification = new ProductNotification(
                "UPDATED", 
                product.getProductId(), 
                product.getId(), 
                product.getName(), 
                product.getCategory(), 
                product.getPrice(), 
                product.getViewCount()
            );
            
            String message = objectMapper.writeValueAsString(notification);
            redisTemplate.convertAndSend(PRODUCT_UPDATED_CHANNEL, message);
            
            logger.info("Published product updated notification for product: {} (ID: {})", 
                       product.getProductId(), product.getId());
        } catch (JsonProcessingException e) {
            logger.error("Error serializing product updated notification for product: {}", 
                        product.getProductId(), e);
        } catch (Exception e) {
            logger.error("Error publishing product updated notification for product: {}", 
                        product.getProductId(), e);
        }
    }
    
    /**
     * Publica notificación cuando se elimina un producto
     */
    @Override
    public void publishProductDeleted(String productId, Long id) {
        try {
            ProductNotification notification = new ProductNotification(
                "DELETED", 
                productId, 
                id, 
                null, 
                null, 
                null, 
                null
            );
            
            String message = objectMapper.writeValueAsString(notification);
            redisTemplate.convertAndSend(PRODUCT_DELETED_CHANNEL, message);
            
            logger.info("Published product deleted notification for product: {} (ID: {})", productId, id);
        } catch (JsonProcessingException e) {
            logger.error("Error serializing product deleted notification for product: {}", productId, e);
        } catch (Exception e) {
            logger.error("Error publishing product deleted notification for product: {}", productId, e);
        }
    }
    
    /**
     * Publica notificación cuando se visualiza un producto
     */
    @Override
    public void publishProductViewed(Product product) {
        try {
            ProductNotification notification = new ProductNotification(
                "VIEWED", 
                product.getProductId(), 
                product.getId(), 
                product.getName(), 
                product.getCategory(), 
                product.getPrice(), 
                product.getViewCount()
            );
            
            String message = objectMapper.writeValueAsString(notification);
            redisTemplate.convertAndSend(PRODUCT_VIEWED_CHANNEL, message);
            
            logger.debug("Published product viewed notification for product: {} (ID: {})", 
                        product.getProductId(), product.getId());
        } catch (JsonProcessingException e) {
            logger.error("Error serializing product viewed notification for product: {}", 
                        product.getProductId(), e);
        } catch (Exception e) {
            logger.error("Error publishing product viewed notification for product: {}", 
                        product.getProductId(), e);
        }
    }
    
    /**
     * Publica alerta de inventario
     */
    @Override
    public void publishStockAlert(String productSku, int quantity, String alertType) {
        try {
            // Crear un objeto simple para la alerta de inventario
            String alertMessage = String.format(
                "{\"event\":\"STOCK_ALERT\",\"productSku\":\"%s\",\"quantity\":%d,\"alertType\":\"%s\",\"timestamp\":\"%s\"}",
                productSku, quantity, alertType, Instant.now().toString()
            );
            
            redisTemplate.convertAndSend(INVENTORY_ALERT_CHANNEL, alertMessage);
            
            logger.info("Published stock alert for product: {} - Quantity: {}, Type: {}", 
                       productSku, quantity, alertType);
        } catch (Exception e) {
            logger.error("Error publishing stock alert for product: {}", productSku, e);
        }
    }
}
