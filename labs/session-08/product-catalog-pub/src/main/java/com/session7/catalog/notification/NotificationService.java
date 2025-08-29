package com.session7.catalog.notification;

import com.session7.catalog.model.Product;

/**
 * Interfaz para el servicio de notificaciones
 */
public interface NotificationService {
    
    /**
     * Publica notificación cuando se crea un producto
     */
    void publishProductCreated(Product product);
    
    /**
     * Publica notificación cuando se actualiza un producto
     */
    void publishProductUpdated(Product product);
    
    /**
     * Publica notificación cuando se elimina un producto
     */
    void publishProductDeleted(String productId, Long id);
    
    /**
     * Publica notificación cuando se visualiza un producto
     */
    void publishProductViewed(Product product);
    
    /**
     * Publica alerta de inventario
     */
    void publishStockAlert(String productSku, int quantity, String alertType);
}
