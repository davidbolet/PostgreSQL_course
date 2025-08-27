package com.example.redisapp;

import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import java.time.Duration;
import java.util.Optional;

/**
 * Servicio para gestionar las sesiones de usuario en Redis
 */
@Service
public class SessionService {
    
    private final RedisTemplate<String, SessionData> redis;
    
    /**
     * Constructor con inyección de dependencias
     * 
     * @param redis Template de Redis para operaciones de datos
     */
    public SessionService(RedisTemplate<String, SessionData> redis) {
        this.redis = redis;
    }
    
    /**
     * Genera la clave para almacenar en Redis
     * 
     * @param id Identificador de la sesión
     * @return Clave formateada para Redis
     */
    private String key(String id) {
        return "session:" + id;
    }
    
    /**
     * Guarda o actualiza una sesión en Redis
     * 
     * @param data Datos de la sesión a guardar
     * @param ttl Tiempo de vida de la sesión (opcional)
     */
    public void save(SessionData data, Duration ttl) {
        if (ttl != null) {
            redis.opsForValue().set(key(data.getId()), data, ttl);
        } else {
            redis.opsForValue().set(key(data.getId()), data);
        }
    }
    
    /**
     * Obtiene una sesión por su identificador
     * 
     * @param id Identificador de la sesión
     * @return Optional con los datos de la sesión si existe
     */
    public Optional<SessionData> get(String id) {
        return Optional.ofNullable(redis.opsForValue().get(key(id)));
    }
    
    /**
     * Elimina una sesión por su identificador
     * 
     * @param id Identificador de la sesión a eliminar
     * @return true si se eliminó correctamente, false en caso contrario
     */
    public boolean delete(String id) {
        return Boolean.TRUE.equals(redis.delete(key(id)));
    }
}
