package com.session7.catalog.notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

/**
 * Consumidor de notificaciones que escucha los canales de Redis PUB/SUB
 * Esta clase demuestra cómo se pueden procesar las notificaciones
 */
@Component
public class NotificationConsumer implements MessageListener {

    private static final Logger logger = LoggerFactory.getLogger(NotificationConsumer.class);
    
    private final StringRedisTemplate redisTemplate;
    
    public NotificationConsumer(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }
    
    @PostConstruct
    public void subscribeToChannels() {
        // Suscribirse a todos los canales de notificación
        redisTemplate.getConnectionFactory().getConnection()
            .subscribe(this, 
                NotificationPublisher.PRODUCT_CREATED_CHANNEL.getBytes(),
                NotificationPublisher.PRODUCT_UPDATED_CHANNEL.getBytes(),
                NotificationPublisher.PRODUCT_DELETED_CHANNEL.getBytes(),
                NotificationPublisher.PRODUCT_VIEWED_CHANNEL.getBytes(),
                NotificationPublisher.INVENTORY_ALERT_CHANNEL.getBytes()
            );
        
        logger.info("Subscribed to notification channels: {}, {}, {}, {}, {}", 
                   NotificationPublisher.PRODUCT_CREATED_CHANNEL,
                   NotificationPublisher.PRODUCT_UPDATED_CHANNEL,
                   NotificationPublisher.PRODUCT_DELETED_CHANNEL,
                   NotificationPublisher.PRODUCT_VIEWED_CHANNEL,
                   NotificationPublisher.INVENTORY_ALERT_CHANNEL);
    }
    
    @Override
    public void onMessage(Message message, byte[] pattern) {
        String channel = new String(message.getChannel());
        String body = new String(message.getBody());
        
        logger.info("Received notification on channel '{}': {}", channel, body);
        
        // Procesar la notificación según el canal
        switch (channel) {
            case "product:created":
                handleProductCreated(body);
                break;
            case "product:updated":
                handleProductUpdated(body);
                break;
            case "product:deleted":
                handleProductDeleted(body);
                break;
            case "product:viewed":
                handleProductViewed(body);
                break;
            case "inventory:alerts":
                handleInventoryAlert(body);
                break;
            default:
                logger.warn("Unknown notification channel: {}", channel);
        }
    }
    
    private void handleProductCreated(String notification) {
        logger.info("🆕 Product created notification: {}", notification);
        // Aquí podrías implementar lógica específica para productos creados
        // Por ejemplo: enviar emails, actualizar dashboards, etc.
    }
    
    private void handleProductUpdated(String notification) {
        logger.info("✏️ Product updated notification: {}", notification);
        // Aquí podrías implementar lógica específica para productos actualizados
        // Por ejemplo: invalidar caches, notificar a sistemas externos, etc.
    }
    
    private void handleProductDeleted(String notification) {
        logger.info("🗑️ Product deleted notification: {}", notification);
        // Aquí podrías implementar lógica específica para productos eliminados
        // Por ejemplo: limpiar caches, archivar datos, etc.
    }
    
    private void handleProductViewed(String notification) {
        logger.info("👁️ Product viewed notification: {}", notification);
        // Aquí podrías implementar lógica específica para productos visualizados
        // Por ejemplo: analytics, recomendaciones, etc.
    }
    
    private void handleInventoryAlert(String notification) {
        logger.info("⚠️ Inventory alert notification: {}", notification);
        // Aquí podrías implementar lógica específica para alertas de inventario
        // Por ejemplo: enviar emails a administradores, crear tickets, etc.
    }
}
