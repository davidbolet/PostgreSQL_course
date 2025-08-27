# 📮 Colección de Postman - Product Catalog API

Esta colección de Postman incluye todos los endpoints de la API REST para el catálogo de productos.

## 🚀 Importar la Colección

1. **Descargar el archivo**: `Product_Catalog_API.postman_collection.json`
2. **Abrir Postman**
3. **Importar**: File → Import → Seleccionar el archivo JSON
4. **Verificar**: La colección aparecerá en la barra lateral izquierda

## 🔧 Configuración Inicial

### Variables de Entorno

La colección usa variables que se configuran automáticamente:

- **`{{base_url}}`**: URL base de la API (por defecto: `http://localhost:8080`)
- **`{{product_id}}`**: ID de producto de ejemplo (por defecto: `PROD001`)
- **`{{category}}`**: Categoría de ejemplo (por defecto: `Electronics`)

### Personalizar Variables

1. **Variables de Colección**: Click derecho en la colección → Edit → Variables
2. **Variables de Entorno**: Crear un nuevo environment con tus valores
3. **Variables Globales**: Configurar en Postman → Settings → Globals

## 📋 Endpoints Incluidos

### 1. Products - CRUD Operations

#### **Create Product** (POST)
- **URL**: `{{base_url}}/api/products/{productId}`
- **Body**: JSON con nombre, categoría, precio y tags
- **Respuesta**: 200 (éxito) o 400 (producto duplicado)

#### **Get Product** (GET)
- **URL**: `{{base_url}}/api/products/{productId}`
- **Respuesta**: 200 (producto encontrado) o 404 (no encontrado)
- **Nota**: Incrementa automáticamente el contador de vistas

#### **Update Product** (PUT)
- **URL**: `{{base_url}}/api/products/{productId}`
- **Body**: JSON con datos actualizados
- **Respuesta**: 200 (actualizado) o 404 (no encontrado)

#### **Delete Product** (DELETE)
- **URL**: `{{base_url}}/api/products/{productId}`
- **Respuesta**: 200 (eliminado) o 404 (no encontrado)

### 2. Products - Query Operations

#### **Get All Products** (GET)
- **URL**: `{{base_url}}/api/products`
- **Respuesta**: Lista de todos los productos

#### **Search Products** (GET)
- **URL**: `{{base_url}}/api/products/search?q={searchTerm}`
- **Query Params**: `q` (término de búsqueda)
- **Respuesta**: Lista de productos que coinciden

#### **Get Products by Category** (GET)
- **URL**: `{{base_url}}/api/products/category/{category}`
- **Respuesta**: Lista de productos de la categoría especificada

### 3. Products - Statistics & Analytics

#### **Get Top Viewed Products** (GET)
- **URL**: `{{base_url}}/api/products/top?limit={n}`
- **Query Params**: `limit` (número máximo de productos)
- **Respuesta**: Productos ordenados por número de vistas

#### **Get Top Viewed by Category** (GET)
- **URL**: `{{base_url}}/api/products/top/category/{category}?limit={n}`
- **Respuesta**: Top productos más vistos de una categoría

#### **Get Product View Count** (GET)
- **URL**: `{{base_url}}/api/products/{productId}/views`
- **Respuesta**: Contador de vistas del producto

### 4. Test Scenarios

#### **Test Duplicate Product Creation**
- **Propósito**: Verificar que no se pueden crear productos duplicados
- **Secuencia**: 
  1. Crear producto TEST001 (debe devolver 200)
  2. Crear producto TEST001 nuevamente (debe devolver 400)

#### **Test Update Non-existent Product**
- **Propósito**: Verificar manejo de productos inexistentes
- **Resultado**: Debe devolver 404

#### **Test Invalid Product Data**
- **Propósito**: Verificar validación de datos
- **Datos**: Nombre vacío, precio negativo
- **Resultado**: Debe devolver 400

## 🧪 Scripts de Prueba Automática

### Pre-request Scripts
- **Logging**: Registra cada request en la consola
- **Variables**: Configura variables dinámicas si es necesario

### Test Scripts
- **Validación de Status Code**: Verifica que el código sea válido
- **Validación de Campos**: Verifica que las respuestas exitosas tengan campos requeridos
- **Validación de Tiempo**: Verifica que la respuesta sea rápida (< 2 segundos)

## 📊 Ejemplos de Uso

### Crear un Producto de Electrónica

```json
POST {{base_url}}/api/products/PROD001
Content-Type: application/json

{
  "name": "Wireless Headphones",
  "category": "Electronics",
  "price": 199.99,
  "tags": ["wireless", "audio", "bluetooth"]
}
```

### Buscar Productos Gaming

```
GET {{base_url}}/api/products/search?q=gaming
```

### Top 5 Productos Más Vistos

```
GET {{base_url}}/api/products/top?limit=5
```

## 🔍 Códigos de Estado HTTP

- **200 OK**: Operación exitosa
- **201 Created**: Producto creado exitosamente
- **400 Bad Request**: Datos inválidos o producto duplicado
- **404 Not Found**: Producto no encontrado
- **500 Internal Server Error**: Error interno del servidor

## 🚨 Manejo de Errores

### Error 400 - Producto Duplicado
```json
{
  "error": "Product with ID 'PROD001' already exists",
  "code": "PRODUCT_ALREADY_EXISTS",
  "status": 400,
  "timestamp": "2025-08-27T19:07:00.000Z"
}
```

### Error 404 - Producto No Encontrado
```json
{
  "error": "Product with ID 'NONEXISTENT' not found",
  "code": "PRODUCT_NOT_FOUND",
  "status": 404,
  "timestamp": "2025-08-27T19:07:00.000Z"
}
```

## 💡 Consejos de Uso

1. **Orden de Ejecución**: Ejecuta primero los tests de CRUD, luego los de consulta
2. **Datos de Prueba**: Usa IDs únicos para evitar conflictos
3. **Validación**: Revisa los scripts de test para entender las validaciones
4. **Variables**: Personaliza las variables según tu entorno
5. **Logs**: Usa la consola de Postman para debugging

## 🔧 Personalización

### Agregar Nuevos Endpoints
1. Click derecho en la colección → Add Request
2. Configurar método, URL y headers
3. Agregar body si es necesario
4. Configurar tests específicos

### Modificar Scripts de Test
1. Seleccionar request → Tests tab
2. Modificar código JavaScript
3. Guardar cambios

### Crear Nuevos Environments
1. Click en "Environment" → "+" 
2. Configurar variables específicas
3. Seleccionar environment antes de ejecutar requests

## 📞 Soporte

Si encuentras problemas con la colección:
1. Verificar que la API esté ejecutándose
2. Revisar las variables de entorno
3. Verificar la conectividad a la base de datos
4. Revisar los logs de la aplicación Spring Boot
