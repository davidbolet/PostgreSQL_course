package com.example.catalog;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ProductRepository extends CrudRepository<Product, String> {
    
    // Solo métodos básicos que Spring Data Redis soporta nativamente
    List<Product> findByCategory(String category);
    
    // Métodos personalizados se implementarán en el servicio
}
