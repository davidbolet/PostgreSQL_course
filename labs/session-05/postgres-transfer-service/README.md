# Postgres Transfer Service

Un servicio de transferencia bancaria construido con Spring Boot que implementa transferencias de fondos con bloqueo pesimista y optimista, reintentos y auditoría.

## Características

- **Transferencias de fondos** con validación de saldo
- **Bloqueo pesimista** para evitar condiciones de carrera
- **Bloqueo optimista** con reintentos automáticos
- **Auditoría completa** de todas las operaciones
- **API REST** para operaciones bancarias
- **Base de datos PostgreSQL** con esquema optimizado

## Estructura del Proyecto

```
src/main/java/com/example/bank/
├── Application.java                 # Clase principal de Spring Boot
├── controller/
│   └── ApiController.java          # Controlador REST para operaciones bancarias
├── service/
│   └── TransferService.java        # Lógica de negocio para transferencias
├── repository/
│   ├── AccountRepository.java      # Repositorio para cuentas bancarias
│   ├── TransactionRepository.java  # Repositorio para transacciones
│   └── AuditLogRepository.java     # Repositorio para logs de auditoría
└── model/
    ├── Account.java                # Entidad de cuenta bancaria
    ├── Transaction.java            # Entidad de transacción
    ├── AuditLog.java               # Entidad de log de auditoría
    └── TransferResult.java         # Resultado de transferencia
```

## Tecnologías Utilizadas

- **Java 17**
- **Spring Boot 3.3.2**
- **Spring Data JPA**
- **PostgreSQL**
- **Maven**

## Endpoints de la API

### POST /api/seed
Inicializa la base de datos con cuentas de prueba:
- Cuenta A-001: $100.00
- Cuenta A-002: $50.00

### POST /api/transfer
Realiza una transferencia entre cuentas:
- `from`: Número de cuenta origen
- `to`: Número de cuenta destino  
- `amount`: Monto a transferir

## Configuración

El proyecto utiliza `application.properties` para la configuración de la base de datos y `schema.sql` para crear las tablas necesarias.

## Compilación y Ejecución

```bash
# Compilar el proyecto
mvn clean compile

# Empaquetar (sin tests)
mvn package -DskipTests

# Ejecutar
java -jar target/postgres-transfer-service-0.0.1-SNAPSHOT.jar
```

## Características de Seguridad

- **Bloqueo pesimista** en cuentas durante transferencias
- **Validación de saldo** antes de procesar
- **Transacciones atómicas** con rollback automático
- **Reintentos automáticos** en caso de conflictos de bloqueo optimista
- **Auditoría completa** de todas las operaciones

## Base de Datos

El esquema incluye:
- `bank.account`: Cuentas bancarias con control de versión
- `bank.tx`: Transacciones con estado y timestamps
- `bank.audit_log`: Logs de auditoría en formato JSONB
