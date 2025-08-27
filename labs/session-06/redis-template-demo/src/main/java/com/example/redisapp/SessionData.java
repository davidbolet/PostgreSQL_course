package com.example.redisapp;

import java.time.Instant;
import java.util.List;

/**
 * Clase que representa los datos de una sesión de usuario
 */
public class SessionData {
    
    private String id;
    private String username;
    private List<String> roles;
    private Instant lastSeen;
    
    /**
     * Constructor por defecto requerido para deserialización
     */
    public SessionData() {}
    
    /**
     * Constructor con parámetros
     * 
     * @param id Identificador único de la sesión
     * @param username Nombre de usuario
     * @param roles Lista de roles del usuario
     * @param lastSeen Último momento de actividad
     */
    public SessionData(String id, String username, List<String> roles, Instant lastSeen) {
        this.id = id;
        this.username = username;
        this.roles = roles;
        this.lastSeen = lastSeen;
    }
    
    // Getters y Setters
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public List<String> getRoles() {
        return roles;
    }
    
    public void setRoles(List<String> roles) {
        this.roles = roles;
    }
    
    public Instant getLastSeen() {
        return lastSeen;
    }
    
    public void setLastSeen(Instant lastSeen) {
        this.lastSeen = lastSeen;
    }
}
