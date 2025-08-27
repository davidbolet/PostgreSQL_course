# Catálogo de Productos con PostgreSQL

Esta es una aplicación Spring Boot que gestiona un catálogo de productos usando PostgreSQL como base de datos y Spring Data JPA para el acceso a datos.

## Características

- **Gestión de Productos**: CRUD completo para productos
- **Validación de Duplicados**: Previene la creación de productos con IDs duplicados
- **Seguimiento de Vistas**: Contador automático de visualizaciones por producto
- **Búsqueda**: Búsqueda por nombre o categoría
- **Categorías**: Filtrado por categorías
- **Productos Más Vistos**: Ranking de productos por número de visualizaciones
- **Tags**: Sistema de etiquetas para productos
- **API REST**: Endpoints RESTful para todas las operaciones
- **Manejo de Errores**: Códigos de estado HTTP apropiados y mensajes de error descriptivos

## Tecnologías

- Java 17
- Spring Boot 3.3.2
- Spring Data JPA
- PostgreSQL
- Maven

## Requisitos Previos

- Java 17 o superior
- PostgreSQL 12 o superior
- Maven 3.6 o superior

## Configuración de la Base de Datos

1. **Instalar PostgreSQL** (si no está instalado)
2. **Crear la base de datos**:
   ```sql
   CREATE DATABASE product_catalog;
   ```
3. **Ejecutar el esquema** (opcional, Hibernate lo creará automáticamente):
   ```bash
   psql -d product_catalog -f src/main/resources/schema.sql
   ```

## Configuración de la Aplicación

### Variables de Entorno

```bash
# Base de datos
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=product_catalog
export DB_USER=postgres
export DB_PASSWORD=postgres

# Puerto del servidor
export PORT=8080
```

### Archivo application.properties

El archivo ya está configurado con valores por defecto que puedes sobrescribir con variables de entorno.

## Ejecutar la Aplicación

1. **Clonar y compilar**:
   ```bash
   mvn clean compile
   ```

2. **Ejecutar**:
   ```bash
   mvn spring-boot:run
   ```

3. **Acceder a la aplicación**:
   ```
   http://localhost:8080
   ```

## API Endpoints

### Productos

- `POST /api/products/{productId}` - Crear nuevo producto
- `PUT /api/products/{productId}` - Actualizar producto existente
- `GET /api/products/{productId}` - Obtener producto (incrementa contador de vistas)
- `DELETE /api/products/{productId}` - Eliminar producto
- `GET /api/products` - Listar todos los productos
- `GET /api/products/search?q={term}` - Buscar productos
- `GET /api/products/category/{category}` - Productos por categoría

### Estadísticas

- `GET /api/products/top?limit={n}` - Top N productos más vistos
- `GET /api/products/top/category/{category}?limit={n}` - Top N por categoría
- `GET /api/products/{productId}/views` - Contador de vistas de un producto

## Códigos de Estado HTTP

- **200 OK**: Operación exitosa
- **201 Created**: Producto creado exitosamente
- **400 Bad Request**: 
  - Datos de entrada inválidos
  - Producto con ID duplicado
  - Validaciones fallidas (nombre vacío, precio negativo)
- **404 Not Found**: Producto no encontrado
- **500 Internal Server Error**: Error interno del servidor

## Ejemplos de Uso

### Crear un Producto

```bash
curl -X POST http://localhost:8080/api/products/PROD006 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wireless Headphones",
    "category": "Electronics",
    "price": 199.99,
    "tags": ["wireless", "audio", "bluetooth"]
  }'
```

### Intentar Crear Producto Duplicado (Devuelve 400)

```bash
# Primera vez - éxito
curl -X POST http://localhost:8080/api/products/PROD007 \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "category": "Test", "price": 99.99}'

# Segunda vez - error 400
curl -X POST http://localhost:8080/api/products/PROD007 \
  -H "Content-Type: application/json" \
  -d '{"name": "Another Product", "category": "Test", "price": 149.99}'
```

### Actualizar un Producto

```bash
curl -X PUT http://localhost:8080/api/products/PROD006 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Headphones",
    "category": "Electronics",
    "price": 249.99,
    "tags": ["wireless", "audio", "bluetooth", "premium"]
  }'
```

### Obtener un Producto

```bash
curl http://localhost:8080/api/products/PROD001
```

### Top Productos Más Vistos

```bash
curl "http://localhost:8080/api/products/top?limit=5"
```

### Buscar Productos

```bash
curl "http://localhost:8080/api/products/search?q=gaming"
```

## Scripts de Prueba

### Prueba General de la API
```bash
./test-api.sh
```

### Prueba de Productos Duplicados
```bash
./test-duplicate.sh
```

## Estructura de la Base de Datos

### Tabla `products`
- `id`: ID interno (autoincremental)
- `product_id`: ID único del producto
- `name`: Nombre del producto
- `category`: Categoría del producto
- `price`: Precio del producto
- `updated_at`: Fecha de última actualización
- `view_count`: Contador de visualizaciones

### Tabla `product_tags`
- `product_id`: Referencia al producto
- `tag`: Etiqueta del producto

## Manejo de Errores

La aplicación incluye un `GlobalExceptionHandler` que maneja:

- **ProductAlreadyExistsException**: Cuando se intenta crear un producto con ID duplicado
- **ProductNotFoundException**: Cuando se intenta actualizar/eliminar un producto inexistente
- **Excepciones genéricas**: Errores internos del servidor

### Ejemplo de Respuesta de Error

```json
{
  "error": "Product with ID 'PROD007' already exists",
  "code": "PRODUCT_ALREADY_EXISTS",
  "status": 400,
  "timestamp": "2025-08-27T19:07:00.000Z"
}
```

## Desarrollo

### Compilar y Ejecutar Tests

```bash
mvn clean test
```

### Ejecutar con Perfil de Desarrollo

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

## Notas

- La aplicación usa `spring.jpa.hibernate.ddl-auto=update`, por lo que Hibernate actualizará automáticamente el esquema de la base de datos
- Los contadores de vista se incrementan automáticamente cada vez que se consulta un producto
- La búsqueda es case-insensitive y busca tanto en nombres como en categorías
- Los tags se almacenan en una tabla separada para normalización
- **NUEVO**: Los productos duplicados devuelven código 400 (Bad Request) en lugar de sobrescribir
- **NUEVO**: Endpoint PUT separado para actualizaciones (más semánticamente correcto)
