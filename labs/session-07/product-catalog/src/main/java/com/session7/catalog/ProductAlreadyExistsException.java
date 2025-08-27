package com.session7.catalog;

public class ProductAlreadyExistsException extends RuntimeException {
    
    public ProductAlreadyExistsException(String message) {
        super(message);
    }
    
    public ProductAlreadyExistsException(String message, Throwable cause) {
        super(message, cause);
    }
}
