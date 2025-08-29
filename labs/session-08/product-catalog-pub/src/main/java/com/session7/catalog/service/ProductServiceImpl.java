package com.session7.catalog.service;

import com.session7.catalog.model.Product;
import com.session7.catalog.repository.ProductRepository;
import com.session7.catalog.exception.ProductAlreadyExistsException;
import com.session7.catalog.exception.ProductNotFoundException;
import com.session7.catalog.notification.NotificationService;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final NotificationService notificationService;

    public ProductServiceImpl(ProductRepository productRepository, NotificationService notificationService) {
        this.productRepository = productRepository;
        this.notificationService = notificationService;
    }

    /** Create a new product. Throws exception if productId already exists. */
    @CachePut(value = "products", key = "#product.productId")
    public Product createProduct(Product product) {
        if (productRepository.existsByProductId(product.getProductId())) {
            throw new ProductAlreadyExistsException("Product with ID '" + product.getProductId() + "' already exists");
        }
        
        product.setUpdatedAt(Instant.now());
        if (product.getViewCount() == null) {
            product.setViewCount(0L);
        }
        Product savedProduct = productRepository.save(product);
        
        // Publicar notificación de producto creado
        notificationService.publishProductCreated(savedProduct);
        
        return savedProduct;
    }

    /** Update an existing product. */
    @CachePut(value = "products", key = "#product.productId")
    @CacheEvict(value = "productsByCategory", key = "#product.category")
    public Product updateProduct(Product product) {
        // Find the existing product by productId
        Product existingProduct = productRepository.findByProductId(product.getProductId())
                .orElseThrow(() -> new ProductNotFoundException("Product with ID '" + product.getProductId() + "' not found"));
        
        // Update the existing product's fields
        existingProduct.setName(product.getName());
        existingProduct.setCategory(product.getCategory());
        existingProduct.setPrice(product.getPrice());
        existingProduct.setUpdatedAt(Instant.now());
        
        // Save the updated existing product (this will be an UPDATE, not INSERT)
        Product updatedProduct = productRepository.save(existingProduct);
        
        // Publicar notificación de producto actualizado
        notificationService.publishProductUpdated(updatedProduct);
        
        return updatedProduct;
    }

    /** Save a product (legacy method - use createProduct or updateProduct instead). */
    public Product save(Product product) {
        product.setUpdatedAt(Instant.now());
        if (product.getViewCount() == null) {
            product.setViewCount(0L);
        }
        return productRepository.save(product);
    }

    /** Get product by productId and increment its view count. */
    @Cacheable(value = "products", key = "#productId")
    public Optional<Product> getAndTrackView(String productId) {
        Optional<Product> productOpt = productRepository.findByProductId(productId);
        if (productOpt.isPresent()) {
            productRepository.incrementViewCount(productId);
            productOpt.get().incrementViewCount();
            
            // Publicar notificación de producto visualizado
            notificationService.publishProductViewed(productOpt.get());
            
            return productOpt;
        }
        return Optional.empty();
    }

    /** Remove a product. */
    @CacheEvict(value = "products", key = "#productId")
    public boolean delete(String productId) {
        if (productRepository.existsByProductId(productId)) {
            // Obtener el ID del producto antes de eliminarlo para la notificación
            Long productIdLong = productRepository.findByProductId(productId)
                    .map(Product::getId)
                    .orElse(null);
            
            productRepository.deleteByProductId(productId);
            
            // Publicar notificación de producto eliminado
            if (productIdLong != null) {
                notificationService.publishProductDeleted(productId, productIdLong);
            }
            
            return true;
        }
        return false;
    }

    /** Get top-N most viewed products. */
    @Cacheable(value = "topProducts", key = "#limit")
    public List<Product> topViewed(int limit) {
        List<Product> allProducts = productRepository.findTopViewedProducts();
        if (limit > 0 && limit < allProducts.size()) {
            return allProducts.subList(0, limit);
        }
        return allProducts;
    }

    /** Get top-N most viewed products by category. */
    @Cacheable(value = "productsByCategory", key = "#category + '_' + #limit")
    public List<Product> topViewedByCategory(String category, int limit) {
        List<Product> products = productRepository.findTopViewedByCategory(category);
        if (limit > 0 && limit < products.size()) {
            return products.subList(0, limit);
        }
        return products;
    }

    /** Search products by name or category. */
    @Cacheable(value = "searchResults", key = "#searchTerm")
    public List<Product> searchProducts(String searchTerm) {
        return productRepository.searchProducts(searchTerm);
    }

    /** Get raw view count for a productId. */
    public Long getViewCount(String productId) {
        return productRepository.findByProductId(productId)
                .map(Product::getViewCount)
                .orElse(0L);
    }

    /** Get all products. */
    @Cacheable(value = "allProducts")
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    /** Check if product exists. */
    public boolean exists(String productId) {
        return productRepository.existsByProductId(productId);
    }

    @CacheEvict(value = {"products", "topProducts", "productsByCategory", "searchResults", "allProducts"}, allEntries = true)
    public void clearProductCache() {
        System.out.println("Clearing all products from cache");
    }
}
