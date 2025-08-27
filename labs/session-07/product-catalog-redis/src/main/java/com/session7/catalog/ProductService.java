package com.session7.catalog;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Optional;


public interface ProductService {

    Product createProduct(Product product);
	Product updateProduct(Product product);
	Optional<Product> getAndTrackView(String productId);
	boolean delete(String productId);
	List<Product> topViewed(int limit);
	List<Product> topViewedByCategory(String category, int limit);
	List<Product> searchProducts(String searchTerm);
	Long getViewCount(String productId);
	List<Product> getAllProducts();
	boolean exists(String productId);
}
