# Product Catalog with PostgreSQL and Redis

This is a Spring Boot application that manages a product catalog using PostgreSQL as the primary database and Redis for caching. The application provides a complete REST API for product management with view tracking, search capabilities, and performance optimization through Redis caching.

## Features

- **Product Management**: Complete CRUD operations for products
- **Duplicate Prevention**: Prevents creation of products with duplicate IDs
- **View Tracking**: Automatic view counter increment for each product
- **Search Functionality**: Search products by name or category
- **Category Filtering**: Filter products by categories
- **Top Products**: Ranking of products by view count
- **Tag System**: Product tagging system for better organization
- **REST API**: RESTful endpoints for all operations
- **Error Handling**: Appropriate HTTP status codes and descriptive error messages
- **Redis Caching**: Performance optimization with Redis caching
- **Validation**: Input validation with proper error responses

## Technologies

- **Java 17**
- **Spring Boot 3.3.2**
- **Spring Data JPA**
- **PostgreSQL** (Primary Database)
- **Redis** (Caching Layer)
- **Maven**
- **Hibernate**

## Prerequisites

- Java 17 or higher
- PostgreSQL 12 or higher
- Redis 6.0 or higher
- Maven 3.6 or higher

## Database Setup

1. **Install PostgreSQL** (if not already installed)
2. **Create the database**:
   ```sql
   CREATE DATABASE product_catalog;
   ```
3. **Run the schema** (optional, Hibernate will create it automatically):
   ```bash
   psql -d product_catalog -f src/main/resources/schema.sql
   ```

## Redis Setup

1. **Install Redis** (if not already installed)
2. **Start Redis server**:
   ```bash
   redis-server
   ```
3. **Verify Redis is running**:
   ```bash
   redis-cli ping
   ```

## Application Configuration

### Environment Variables

```bash
# Database Configuration
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=product_catalog
export DB_USER=postgres
export DB_PASSWORD=postgres

# Redis Configuration
export REDIS_HOST=localhost
export REDIS_PORT=6379

# Server Configuration
export PORT=8080
```

### Application Properties

The `application.properties` file is pre-configured with default values that can be overridden with environment variables. Key configurations include:

- PostgreSQL connection settings
- Redis connection settings
- JPA/Hibernate configuration
- Cache configuration with Redis
- Server port configuration

## Running the Application

1. **Clone and compile**:
   ```bash
   mvn clean compile
   ```

2. **Run the application**:
   ```bash
   mvn spring-boot:run
   ```

3. **Access the application**:
   ```
   http://localhost:8080
   ```

## API Endpoints

### Products

- `POST /api/products/{productId}` - Create new product
- `PUT /api/products/{productId}` - Update existing product
- `GET /api/products/{productId}` - Get product (increments view counter)
- `DELETE /api/products/{productId}` - Delete product
- `GET /api/products` - List all products
- `GET /api/products/search?q={term}` - Search products
- `GET /api/products/category/{category}` - Products by category

### Statistics

- `GET /api/products/top?limit={n}` - Top N most viewed products
- `GET /api/products/top/category/{category}?limit={n}` - Top N by category
- `GET /api/products/{productId}/views` - View count for a product

## HTTP Status Codes

- **200 OK**: Successful operation
- **201 Created**: Product created successfully
- **400 Bad Request**: 
  - Invalid input data
  - Duplicate product ID
  - Validation failures (empty name, negative price)
- **404 Not Found**: Product not found
- **500 Internal Server Error**: Internal server error

## Usage Examples

### Create a Product

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

### Attempt to Create Duplicate Product (Returns 400)

```bash
# First time - success
curl -X POST http://localhost:8080/api/products/PROD007 \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Product", "category": "Test", "price": 99.99}'

# Second time - error 400
curl -X POST http://localhost:8080/api/products/PROD007 \
  -H "Content-Type: application/json" \
  -d '{"name": "Another Product", "category": "Test", "price": 149.99}'
```

### Update a Product

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

### Get a Product

```bash
curl http://localhost:8080/api/products/PROD001
```

### Top Most Viewed Products

```bash
curl "http://localhost:8080/api/products/top?limit=5"
```

### Search Products

```bash
curl "http://localhost:8080/api/products/search?q=gaming"
```

## Database Schema

### `products` Table
- `id`: Internal ID (auto-incremental)
- `product_id`: Unique product identifier
- `name`: Product name
- `category`: Product category
- `price`: Product price
- `updated_at`: Last update timestamp
- `view_count`: View counter

### `product_tags` Table
- `product_id`: Reference to product
- `tag`: Product tag

## Caching Strategy

The application uses Redis for caching with the following strategy:

- **Product Cache**: Caches individual products by product ID
- **Category Cache**: Caches products grouped by category
- **Cache Eviction**: Automatically evicts related caches when products are updated
- **TTL**: Cache entries expire after 1 hour (configurable)

### Cache Annotations Used

- `@Cacheable`: For read operations
- `@CachePut`: For create/update operations
- `@CacheEvict`: For delete operations and cache invalidation

## Error Handling

The application includes a `GlobalExceptionHandler` that handles:

- **ProductAlreadyExistsException**: When attempting to create a product with duplicate ID
- **ProductNotFoundException**: When attempting to update/delete a non-existent product
- **Generic exceptions**: Internal server errors

### Error Response Example

```json
{
  "error": "Product with ID 'PROD007' already exists",
  "code": "PRODUCT_ALREADY_EXISTS",
  "status": 400,
  "timestamp": "2025-08-27T19:07:00.000Z"
}
```

## Development

### Compile and Run Tests

```bash
mvn clean test
```

### Run with Development Profile

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### Build JAR

```bash
mvn clean package
```

## Performance Features

- **Redis Caching**: Reduces database load for frequently accessed data
- **Database Indexes**: Optimized queries with proper indexing
- **Lazy Loading**: Efficient data fetching strategies
- **Connection Pooling**: Optimized database connections

## Notes

- The application uses `spring.jpa.hibernate.ddl-auto=update`, so Hibernate will automatically update the database schema
- View counters are automatically incremented each time a product is accessed
- Search is case-insensitive and searches both names and categories
- Tags are stored in a separate table for normalization
- Redis caching significantly improves response times for frequently accessed data
- The application includes proper transaction management with `@Transactional` annotations

## Troubleshooting

### Common Issues

1. **Redis Connection Failed**: Ensure Redis server is running on localhost:6379
2. **Database Connection Failed**: Verify PostgreSQL is running and credentials are correct
3. **Port Already in Use**: Change the server port in `application.properties` or set `PORT` environment variable

### Logs

Enable debug logging by setting in `application.properties`:
```properties
logging.level.com.session7.catalog=DEBUG
logging.level.org.springframework.cache=DEBUG
```
