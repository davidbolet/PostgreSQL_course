package com.session7.catalog;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    Optional<Product> findByProductId(String productId);
    
    boolean existsByProductId(String productId);
    
    @Modifying
    @Query("UPDATE Product p SET p.viewCount = p.viewCount + 1 WHERE p.productId = :productId")
    void incrementViewCount(@Param("productId") String productId);
    
    @Query("SELECT p FROM Product p ORDER BY p.viewCount DESC")
    List<Product> findTopViewedProducts();
    
    @Query("SELECT p FROM Product p WHERE p.category = :category ORDER BY p.viewCount DESC")
    List<Product> findTopViewedByCategory(@Param("category") String category);
    
    @Query("SELECT p FROM Product p WHERE p.name LIKE %:searchTerm% OR p.category LIKE %:searchTerm%")
    List<Product> searchProducts(@Param("searchTerm") String searchTerm);
    
    void deleteByProductId(String productId);
}
