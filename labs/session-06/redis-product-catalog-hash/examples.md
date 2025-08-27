# Ejemplos de Uso - Redis Product Catalog con Repositories

## Configuración Inicial

Asegúrate de tener Redis ejecutándose:
```bash
docker run -p 6379:6379 --name redis -d redis:7
```

## Ejecutar la Aplicación
```bash
mvn spring-boot:run
```

## Ejemplos de Uso de la API

### 1. Crear Productos

```bash
# Producto de electrónica
curl -X POST "http://localhost:8080/api/products/laptop-001" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Pro 16\"",
    "category": "electronics",
    "tags": ["laptop", "apple", "professional"],
    "price": 2499.99
  }'

# Producto de ropa
curl -X POST "http://localhost:8080/api/products/shirt-001" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Camisa de Algodón Premium",
    "category": "clothing",
    "tags": ["shirt", "cotton", "casual"],
    "price": 49.99
  }'

# Producto de libros
curl -X POST "http://localhost:8080/api/products/book-001" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Clean Code",
    "category": "books",
    "tags": ["programming", "software", "best-practices"],
    "price": 39.99
  }'

# Producto con TTL (expira en 2 minutos)
curl -X POST "http://localhost:8080/api/products/flash-sale-001?ttlSeconds=120" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Oferta Flash - Auriculares",
    "category": "electronics",
    "tags": ["headphones", "sale", "limited"],
    "price": 19.99
  }'
```

### 2. Consultas del Repositorio

#### Búsqueda por Categoría
```bash
# Todos los productos de electrónica
curl "http://localhost:8080/api/products/category/electronics"

# Todos los productos de ropa
curl "http://localhost:8080/api/products/category/clothing"
```

#### Búsqueda por Precio
```bash
# Productos entre $20 y $100
curl "http://localhost:8080/api/products/price/range?minPrice=20&maxPrice=100"

# Productos menores a $50
curl "http://localhost:8080/api/products/price/less-than?price=50"

# Productos mayores a $1000
curl "http://localhost:8080/api/products/price/greater-than?price=1000"
```

#### Búsqueda por Tags
```bash
# Productos que contengan el tag "sale"
curl "http://localhost:8080/api/products/tags?tag=sale"

# Productos que contengan el tag "professional"
curl "http://localhost:8080/api/products/tags?tag=professional"
```

#### Búsqueda por Fecha
```bash
# Productos agregados en los últimos 7 días
curl "http://localhost:8080/api/products/recent?daysAgo=7"

# Productos agregados en los últimos 24 horas
curl "http://localhost:8080/api/products/recent?daysAgo=1"
```

#### Búsqueda Combinada
```bash
# Productos de electrónica entre $100 y $3000
curl "http://localhost:8080/api/products/search?category=electronics&minPrice=100&maxPrice=3000"
```

### 3. Funcionalidades Existentes

#### Obtener Producto por ID
```bash
curl "http://localhost:8080/api/products/laptop-001"
```

#### Productos Más Vistos
```bash
# Top 5 productos más vistos
curl "http://localhost:8080/api/products/top?limit=5"
```

#### Contador de Vistas
```bash
curl "http://localhost:8080/api/products/laptop-001/views"
```

#### Eliminar Producto
```bash
curl -X DELETE "http://localhost:8080/api/products/flash-sale-001"
```

## Casos de Uso Avanzados

### 1. Catálogo de E-commerce
```bash
# Crear múltiples productos de diferentes categorías
for i in {1..5}; do
  curl -X POST "http://localhost:8080/api/products/phone-$i" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"Smartphone Model $i\",
      \"category\": \"electronics\",
      \"tags\": [\"phone\", \"mobile\", \"smartphone\"],
      \"price\": $((500 + $i * 100))
    }"
done

# Buscar todos los smartphones
curl "http://localhost:8080/api/products/category/electronics"

# Filtrar por rango de precio
curl "http://localhost:8080/api/products/price/range?minPrice=500&maxPrice=1000"
```

### 2. Sistema de Ofertas con TTL
```bash
# Crear ofertas que expiran
curl -X POST "http://localhost:8080/api/products/offer-1?ttlSeconds=300" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Oferta Especial - 50% OFF",
    "category": "promotions",
    "tags": ["offer", "discount", "limited-time"],
    "price": 25.00
  }'

# Verificar que la oferta existe
curl "http://localhost:8080/api/products/offer-1"

# Esperar 5 minutos y verificar que expiró
sleep 300
curl "http://localhost:8080/api/products/offer-1"
```

### 3. Análisis de Productos Recientes
```bash
# Crear productos con diferentes fechas
curl -X POST "http://localhost:8080/api/products/new-product-1" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Producto Nuevo 1",
    "category": "new-releases",
    "tags": ["new", "featured"],
    "price": 99.99
  }'

# Ver productos agregados recientemente
curl "http://localhost:8080/api/products/recent?daysAgo=1"
```

## Verificación de Índices

Los índices se crean automáticamente en Redis. Puedes verificar su funcionamiento:

```bash
# Conectar a Redis CLI
redis-cli

# Ver las claves de índice
KEYS *:idx:*

# Ver el índice de categorías
HGETALL product:idx:category

# Ver el índice de precios
HGETALL product:idx:price
```

## Monitoreo de Rendimiento

```bash
# Ver estadísticas de Redis
redis-cli info

# Ver comandos más usados
redis-cli info stats

# Monitorear comandos en tiempo real
redis-cli monitor
```

## Limpieza

```bash
# Eliminar todos los productos
redis-cli FLUSHDB

# O eliminar productos específicos
curl -X DELETE "http://localhost:8080/api/products/laptop-001"
curl -X DELETE "http://localhost:8080/api/products/shirt-001"
curl -X DELETE "http://localhost:8080/api/products/book-001"
```
