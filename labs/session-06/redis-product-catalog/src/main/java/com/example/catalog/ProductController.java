package com.example.catalog;

import jakarta.validation.Valid;
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

    @PostMapping("/{id}")
    public ResponseEntity<?> upsert(@PathVariable String id,
                                    @RequestParam(required = false) Long ttlSeconds,
                                    @RequestBody Product body) {
        body.setId(id);
        // Validar después de establecer el id
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
        
        service.save(body, ttlSeconds);
        Map<String, Object> response = new HashMap<>();
        response.put("saved", true);
        response.put("id", id);
        response.put("ttlSeconds", ttlSeconds);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable String id) {
        return service.getAndTrackView(id)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id) {
        boolean deleted = service.delete(id);
        Map<String, Boolean> response = new HashMap<>();
        response.put("deleted", deleted);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/top")
    public ResponseEntity<List<Product>> top(@RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(service.topViewed(limit));
    }

    @GetMapping("/{id}/views")
    public ResponseEntity<?> views(@PathVariable String id) {
        Double score = service.getViewScore(id);
        Map<String, Object> response = new HashMap<>();
        response.put("id", id);
        response.put("views", score == null ? 0 : score.longValue());
        return ResponseEntity.ok(response);
    }
}
