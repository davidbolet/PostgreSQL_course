package com.session7.catalog;


import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;

    public ProductServiceImpl(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    /** Create a new product. Throws exception if productId already exists. */
    public Product createProduct(Product product) {
        if (productRepository.existsByProductId(product.getProductId())) {
            throw new ProductAlreadyExistsException("Product with ID '" + product.getProductId() + "' already exists");
        }
        
        product.setUpdatedAt(Instant.now());
        if (product.getViewCount() == null) {
            product.setViewCount(0L);
        }
        return productRepository.save(product);
    }

    /** Update an existing product. */
    public Product updateProduct(Product product) {
        if (!productRepository.existsByProductId(product.getProductId())) {
            throw new ProductNotFoundException("Product with ID '" + product.getProductId() + "' not found");
        }
        
        product.setUpdatedAt(Instant.now());
        return productRepository.save(product);
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
    public Optional<Product> getAndTrackView(String productId) {
        Optional<Product> productOpt = productRepository.findByProductId(productId);
        if (productOpt.isPresent()) {
            productRepository.incrementViewCount(productId);
            productOpt.get().incrementViewCount();
            return productOpt;
        }
        return Optional.empty();
    }

    /** Remove a product. */
    public boolean delete(String productId) {
        if (productRepository.existsByProductId(productId)) {
            productRepository.deleteByProductId(productId);
            return true;
        }
        return false;
    }

    /** Get top-N most viewed products. */
    public List<Product> topViewed(int limit) {
        List<Product> allProducts = productRepository.findTopViewedProducts();
        if (limit > 0 && limit < allProducts.size()) {
            return allProducts.subList(0, limit);
        }
        return allProducts;
    }

    /** Get top-N most viewed products by category. */
    public List<Product> topViewedByCategory(String category, int limit) {
        List<Product> products = productRepository.findTopViewedByCategory(category);
        if (limit > 0 && limit < products.size()) {
            return products.subList(0, limit);
        }
        return products;
    }

    /** Search products by name or category. */
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
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    /** Check if product exists. */
    public boolean exists(String productId) {
        return productRepository.existsByProductId(productId);
    }
    
}
