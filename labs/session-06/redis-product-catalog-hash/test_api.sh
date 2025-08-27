#!/bin/bash

# Script de prueba automática para Redis Product Catalog API
# Uso: ./test_api.sh [base_url]
# Ejemplo: ./test_api.sh http://localhost:8080

# Configuración por defecto
BASE_URL=${1:-"http://localhost:8080"}
API_BASE="$BASE_URL/api/products"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Función para hacer requests HTTP
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    print_status "Probando: $description"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$endpoint")
    fi
    
    # Separar respuesta y código de estado de manera más robusta
    if [ -n "$response" ]; then
        # Verificar si hay más de una línea
        local line_count=$(echo "$response" | wc -l)
        if [ "$line_count" -gt 1 ]; then
            http_code=$(echo "$response" | tail -n1)
            response_body=$(echo "$response" | head -n -1)
        else
            # Solo hay una línea (código HTTP)
            http_code="$response"
            response_body=""
        fi
    else
        http_code="000"
        response_body=""
    fi
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        print_success "✅ $description - HTTP $http_code"
        if [ -n "$response_body" ]; then
            echo "Respuesta: $response_body" | head -c 100
            echo "..."
        fi
    else
        print_error "❌ $description - HTTP $http_code"
        if [ -n "$response_body" ]; then
            echo "Respuesta: $response_body"
        fi
    fi
    echo ""
}

# Función para esperar que la API esté disponible
wait_for_api() {
    print_status "Esperando que la API esté disponible en $BASE_URL..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$BASE_URL/actuator/health" > /dev/null 2>&1; then
            print_success "API disponible después de $attempt intentos"
            return 0
        fi
        
        print_status "Intento $attempt/$max_attempts - API no disponible, esperando..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    print_error "La API no está disponible después de $max_attempts intentos"
    return 1
}

# Función para verificar que Redis esté funcionando
check_redis() {
    print_status "Verificando conexión a Redis..."
    
    if command -v redis-cli &> /dev/null; then
        if redis-cli ping > /dev/null 2>&1; then
            print_success "Redis está funcionando"
            return 0
        else
            print_warning "Redis CLI disponible pero no responde"
        fi
    else
        print_warning "Redis CLI no está instalado"
    fi
    
    print_status "Continuando sin verificación de Redis..."
    return 0
}

# Función para limpiar Redis
cleanup_redis() {
    print_status "🧹 Limpiando Redis para evitar conflictos de tipos de datos..."
    
    if command -v redis-cli &> /dev/null; then
        if redis-cli FLUSHDB > /dev/null 2>&1; then
            print_success "Redis limpiado exitosamente"
        else
            print_warning "No se pudo limpiar Redis, continuando..."
        fi
    else
        print_warning "Redis CLI no disponible, continuando sin limpieza..."
    fi
    
    # Esperar un momento para que Redis se estabilice
    sleep 1
}

# Función principal de pruebas
run_tests() {
    print_status "🚀 Iniciando pruebas de la API Redis Product Catalog"
    print_status "URL base: $BASE_URL"
    echo ""
    
    # Limpiar Redis antes de las pruebas
    cleanup_redis
    
    # Verificar Redis
    check_redis
    
    # Verificar que la API esté disponible
    if ! wait_for_api; then
        exit 1
    fi
    
    # 1. Crear productos de ejemplo
    print_status "📦 Creando productos de ejemplo..."
    
    make_request "POST" "$API_BASE/laptop-001" \
        '{"name":"MacBook Pro 16\"","category":"electronics","tags":["laptop","apple","professional"],"price":2499.99}' \
        "Crear laptop de ejemplo"
    
    make_request "POST" "$API_BASE/shirt-001" \
        '{"name":"Camisa de Algodón Premium","category":"clothing","tags":["shirt","cotton","casual"],"price":49.99}' \
        "Crear camisa de ejemplo"
    
    make_request "POST" "$API_BASE/book-001" \
        '{"name":"Clean Code","category":"books","tags":["programming","software","best-practices"],"price":39.99}' \
        "Crear libro de ejemplo"
    
    make_request "POST" "$API_BASE/flash-sale-001?ttlSeconds=300" \
        '{"name":"Oferta Flash - Auriculares","category":"electronics","tags":["headphones","sale","limited"],"price":19.99}' \
        "Crear oferta flash con TTL (5 minutos)"
    
    # 2. Probar operaciones CRUD básicas
    print_status "🔍 Probando operaciones CRUD básicas..."
    
    make_request "GET" "$API_BASE/laptop-001" \
        "" \
        "Obtener laptop por ID"
    
    make_request "GET" "$API_BASE/shirt-001" \
        "" \
        "Obtener camisa por ID"
    
    # 3. Probar búsquedas por categoría
    print_status "🏷️ Probando búsquedas por categoría..."
    
    make_request "GET" "$API_BASE/category/electronics" \
        "" \
        "Buscar productos de electrónica"
    
    make_request "GET" "$API_BASE/category/clothing" \
        "" \
        "Buscar productos de ropa"
    
    make_request "GET" "$API_BASE/category/books" \
        "" \
        "Buscar productos de libros"
    
    # 4. Probar búsquedas por precio (implementación personalizada)
    print_status "💰 Probando búsquedas por precio (implementación personalizada)..."
    
    make_request "GET" "$API_BASE/price/range?minPrice=20&maxPrice=100" \
        "" \
        "Buscar productos entre $20 y $100"
    
    make_request "GET" "$API_BASE/price/less-than?price=50" \
        "" \
        "Buscar productos menores a $50"
    
    make_request "GET" "$API_BASE/price/greater-than?price=1000" \
        "" \
        "Buscar productos mayores a $1000"
    
    # 5. Probar búsquedas por tags (implementación personalizada)
    print_status "🏷️ Probando búsquedas por tags (implementación personalizada)..."
    
    make_request "GET" "$API_BASE/tags?tag=sale" \
        "" \
        "Buscar productos con tag 'sale'"
    
    make_request "GET" "$API_BASE/tags?tag=professional" \
        "" \
        "Buscar productos con tag 'professional'"
    
    # 6. Probar búsquedas por fecha
    print_status "📅 Probando búsquedas por fecha..."
    
    make_request "GET" "$API_BASE/recent?daysAgo=7" \
        "" \
        "Buscar productos de los últimos 7 días"
    
    make_request "GET" "$API_BASE/recent?daysAgo=1" \
        "" \
        "Buscar productos de las últimas 24 horas"
    
    # 7. Probar búsquedas combinadas (implementación personalizada)
    print_status "🔍 Probando búsquedas combinadas (implementación personalizada)..."
    
    make_request "GET" "$API_BASE/search?category=electronics&minPrice=100&maxPrice=3000" \
        "" \
        "Buscar productos de electrónica entre $100 y $3000"
    
    # 8. Probar seguimiento de vistas
    print_status "👁️ Probando seguimiento de vistas..."
    
    make_request "GET" "$API_BASE/top?limit=5" \
        "" \
        "Obtener top 5 productos más vistos"
    
    make_request "GET" "$API_BASE/laptop-001/views" \
        "" \
        "Obtener contador de vistas del laptop"
    
    # 9. Probar actualización de productos
    print_status "✏️ Probando actualización de productos..."
    
    make_request "POST" "$API_BASE/laptop-001" \
        '{"name":"MacBook Pro 16\" (Actualizado)","category":"electronics","tags":["laptop","apple","professional","updated"],"price":2599.99}' \
        "Actualizar laptop existente"
    
    # 10. Verificar actualización
    make_request "GET" "$API_BASE/laptop-001" \
        "" \
        "Verificar que el laptop fue actualizado"
    
    # 11. Probar eliminación
    print_status "🗑️ Probando eliminación de productos..."
    
    make_request "DELETE" "$API_BASE/book-001" \
        "" \
        "Eliminar libro de ejemplo"
    
    # 12. Verificar eliminación
    make_request "GET" "$API_BASE/book-001" \
        "" \
        "Verificar que el libro fue eliminado (debería retornar 404)"
    
    print_status "🎉 Todas las pruebas han sido completadas!"
    print_status "📊 Revisa los resultados arriba para ver el estado de cada endpoint"
    
    # Información adicional
    echo ""
    print_status "💡 Para probar productos con TTL, espera 5 minutos y verifica que flash-sale-001 haya expirado"
    print_status "🔍 Puedes usar Redis CLI para inspeccionar los datos: redis-cli KEYS '*'"
    print_status "📚 Consulta POSTMAN_COLLECTION_README.md para más detalles sobre la API"
    
    # Resumen de resultados
    echo ""
    print_status "📋 Resumen de la ejecución:"
    print_status "   - Algunos métodos usan implementación personalizada debido a limitaciones de Spring Data Redis"
    print_status "   - Los métodos de precio y tags se implementan usando streams de Java"
    print_status "   - Las búsquedas combinadas también usan implementación personalizada"
}

# Función de limpieza
cleanup() {
    print_status "🧹 Limpiando datos de prueba..."
    
    # Eliminar productos de prueba
    curl -s -X DELETE "$API_BASE/laptop-001" > /dev/null 2>&1
    curl -s -X DELETE "$API_BASE/shirt-001" > /dev/null 2>&1
    curl -s -X DELETE "$API_BASE/flash-sale-001" > /dev/null 2>&1
    
    print_success "Limpieza completada"
}

# Manejo de señales para limpieza
trap cleanup EXIT

# Verificar dependencias
if ! command -v curl &> /dev/null; then
    print_error "curl no está instalado. Por favor instálalo para continuar."
    exit 1
fi

# Ejecutar pruebas
run_tests

# La función cleanup se ejecutará automáticamente al salir
