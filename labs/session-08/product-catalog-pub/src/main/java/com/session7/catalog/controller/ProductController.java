package com.session7.catalog.controller;

import com.session7.catalog.model.Product;
import com.session7.catalog.service.ProductService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService service;

    public ProductController(ProductService service) {
        this.service = service;
    }

    @PostMapping("/{productId}")
    public ResponseEntity<?> createProduct(@PathVariable String productId,
                                          @RequestBody Product body) {
        body.setProductId(productId);
        // Validar después de establecer el productId
        if (body.getName() == null || body.getName().trim().isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Product name is required");
            return ResponseEntity.badRequest().body(error);
        }
        if (body.getPrice() == null || body.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Product price must be positive");
            return ResponseEntity.badRequest().body(error);
        }
        
        Product savedProduct = service.createProduct(body);
        Map<String, Object> response = new HashMap<>();
        response.put("saved", true);
        response.put("productId", productId);
        response.put("id", savedProduct.getId());
        response.put("message", "Product created successfully");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{productId}")
    public ResponseEntity<?> updateProduct(@PathVariable String productId,
                                          @RequestBody Product body) {
        body.setProductId(productId);
        // Validar después de establecer el productId
        if (body.getName() == null || body.getName().trim().isEmpty()) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Product name is required");
            return ResponseEntity.badRequest().body(error);
        }
        if (body.getPrice() == null || body.getPrice().compareTo(BigDecimal.ZERO) <= 0) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Product price must be positive");
            return ResponseEntity.badRequest().body(error);
        }
        
        Product savedProduct = service.updateProduct(body);
        Map<String, Object> response = new HashMap<>();
        response.put("updated", true);
        response.put("productId", productId);
        response.put("id", savedProduct.getId());
        response.put("message", "Product updated successfully");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{productId}")
    public ResponseEntity<?> get(@PathVariable String productId) {
        return service.getAndTrackView(productId)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{productId}")
    public ResponseEntity<?> delete(@PathVariable String productId) {
        boolean deleted = service.delete(productId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("deleted", deleted);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/top")
    public ResponseEntity<List<Product>> top(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(service.topViewed(limit));
    }

    @GetMapping("/top/category/{category}")
    public ResponseEntity<List<Product>> topByCategory(@PathVariable String category,
                                                      @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(service.topViewedByCategory(category, limit));
    }

    @GetMapping("/{productId}/views")
    public ResponseEntity<?> views(@PathVariable String productId) {
        Long viewCount = service.getViewCount(productId);
        Map<String, Object> response = new HashMap<>();
        response.put("productId", productId);
        response.put("views", viewCount);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/search")
    public ResponseEntity<List<Product>> search(@RequestParam String q) {
        return ResponseEntity.ok(service.searchProducts(q));
    }

    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        return ResponseEntity.ok(service.getAllProducts());
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<List<Product>> getByCategory(@PathVariable String category) {
        return ResponseEntity.ok(service.topViewedByCategory(category, 100));
    }
}
