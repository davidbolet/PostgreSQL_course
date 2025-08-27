# Product Catalog with PostgreSQL

This is a Spring Boot application that manages a product catalog using PostgreSQL as the database and Spring Data JPA for data access.

## Features

- **Product Management**: Complete CRUD operations for products
- **Duplicate Validation**: Prevents creation of products with duplicate IDs
- **View Tracking**: Automatic view counter per product
- **Search**: Search by name or category
- **Categories**: Filtering by categories
- **Most Viewed Products**: Product ranking by number of views
- **Tags**: Product tagging system
- **REST API**: RESTful endpoints for all operations
- **Error Handling**: Appropriate HTTP status codes and descriptive error messages

## Technologies

- Java 17
- Spring Boot 3.3.2
- Spring Data JPA
- PostgreSQL
- Maven

## Prerequisites

- Java 17 or higher
- PostgreSQL 12 or higher
- Maven 3.6 or higher

## Database Configuration

1. **Install PostgreSQL** (if not installed)
2. **Create the database**:
   ```sql
   CREATE DATABASE product_catalog;
   ```
3. **Run the schema** (optional, Hibernate will create it automatically):
   ```bash
   psql -d product_catalog -f src/main/resources/schema.sql
   ```

## Application Configuration

### Environment Variables

```bash
# Database
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=product_catalog
export DB_USER=postgres
export DB_PASSWORD=postgres

# Server port
export PORT=8080
```

### application.properties File

The file is already configured with default values that you can override with environment variables.

## Running the Application

1. **Clone and compile**:
   ```bash
   mvn clean compile
   ```

2. **Run**:
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
- `GET /api/products/{productId}/views` - View counter for a product

## HTTP Status Codes

- **200 OK**: Successful operation
- **201 Created**: Product created successfully
- **400 Bad Request**: 
  - Invalid input data
  - Duplicate product ID
  - Failed validations (empty name, negative price)
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

### Try to Create Duplicate Product (Returns 400)

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

## Database Structure

### `products` Table
- `id`: Internal ID (auto-incremental)
- `product_id`: Unique product identifier
- `name`: Product name
- `category`: Product category
- `price`: Product price
- `updated_at`: Last update date
- `view_count`: View counter

### `product_tags` Table
- `product_id`: Reference to the product
- `tag`: Product tag

## Error Handling

The application includes a `GlobalExceptionHandler` that handles:

- **ProductAlreadyExistsException**: When trying to create a product with duplicate ID
- **ProductNotFoundException**: When trying to update/delete a non-existent product
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

## Notes

- The application uses `spring.jpa.hibernate.ddl-auto=update`, so Hibernate will automatically update the database schema
- View counters are automatically incremented each time a product is queried
- Search is case-insensitive and searches both names and categories
- Tags are stored in a separate table for normalization
- **NEW**: Duplicate products return 400 (Bad Request) instead of overwriting
- **NEW**: Separate PUT endpoint for updates (more semantically correct)
