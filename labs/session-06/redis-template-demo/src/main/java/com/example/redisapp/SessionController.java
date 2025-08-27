package com.example.redisapp;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.Map;

/**
 * Controlador REST para gestionar las sesiones de usuario
 */
@RestController
@RequestMapping("/api/sessions")
public class SessionController {
    
    private final SessionService service;
    
    /**
     * Constructor con inyección de dependencias
     * 
     * @param service Servicio de gestión de sesiones
     */
    public SessionController(SessionService service) {
        this.service = service;
    }
    
    /**
     * Crea o actualiza una sesión de usuario
     * 
     * @param id Identificador único de la sesión
     * @param username Nombre de usuario (por defecto: "user")
     * @param role Lista de roles del usuario (opcional)
     * @param ttlSeconds Tiempo de vida en segundos (opcional)
     * @return Respuesta confirmando la operación
     */
    @PostMapping("/{id}")
    public ResponseEntity<?> createOrUpdate(
            @PathVariable String id,
            @RequestParam(defaultValue = "user") String username,
            @RequestParam(required = false) List<String> role,
            @RequestParam(required = false) Long ttlSeconds) {
        
        SessionData data = new SessionData(
            id, 
            username, 
            role == null ? java.util.Arrays.asList("USER") : role, 
            Instant.now()
        );
        
        Duration ttl = ttlSeconds == null ? null : Duration.ofSeconds(ttlSeconds);
        service.save(data, ttl);
        
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("saved", true);
        response.put("id", id);
        response.put("ttlSeconds", ttlSeconds);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Obtiene una sesión por su identificador
     * 
     * @param id Identificador de la sesión
     * @return Datos de la sesión o 404 si no existe
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable String id) {
        return service.get(id)
            .<ResponseEntity<?>>map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }
    
    /**
     * Elimina una sesión por su identificador
     * 
     * @param id Identificador de la sesión a eliminar
     * @return Respuesta confirmando la eliminación
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id) {
        boolean deleted = service.delete(id);
        Map<String, Object> response = new java.util.HashMap<>();
        response.put("deleted", deleted);
        return ResponseEntity.ok(response);
    }
}
