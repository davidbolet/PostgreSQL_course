#!/bin/bash

# Script para limpiar Redis y evitar conflictos de tipos de datos
# Uso: ./cleanup_redis.sh

echo "🧹 Limpiando Redis para evitar conflictos de tipos de datos..."

# Verificar si redis-cli está disponible
if command -v redis-cli &> /dev/null; then
    echo "✅ Redis CLI encontrado"
    
    # Limpiar toda la base de datos
    echo "🗑️ Limpiando toda la base de datos Redis..."
    redis-cli FLUSHDB
    
    if [ $? -eq 0 ]; then
        echo "✅ Base de datos Redis limpiada exitosamente"
    else
        echo "❌ Error al limpiar Redis"
        exit 1
    fi
    
    # Verificar que esté limpia
    echo "🔍 Verificando que Redis esté limpia..."
    keys_count=$(redis-cli DBSIZE)
    echo "📊 Número de claves en Redis: $keys_count"
    
    if [ "$keys_count" -eq "0" ]; then
        echo "✅ Redis está completamente limpia"
    else
        echo "⚠️ Redis aún tiene $keys_count claves"
    fi
    
else
    echo "⚠️ Redis CLI no está disponible"
    echo "💡 Asegúrate de tener Redis instalado y ejecutándose"
    echo "💡 Puedes instalar Redis CLI con: brew install redis (macOS) o apt-get install redis-tools (Ubuntu)"
fi

echo ""
echo "🎯 Ahora puedes ejecutar la aplicación Spring Boot sin conflictos de tipos de datos"
echo "💡 Ejecuta: mvn spring-boot:run"
