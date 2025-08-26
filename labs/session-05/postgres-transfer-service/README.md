# PostgreSQL Transfer Service

A banking transfer service built with Spring Boot that implements fund transfers with pessimistic and optimistic locking, retries, and audit logging.

## Features

- **Fund transfers** with balance validation
- **Pessimistic locking** to prevent race conditions
- **Optimistic locking** with automatic retries
- **Complete audit** of all operations
- **REST API** for banking operations
- **PostgreSQL database** with optimized schema

## Project Structure

```
src/main/java/com/example/bank/
├── Application.java                 # Spring Boot main class
├── controller/
│   └── ApiController.java          # REST controller for banking operations
├── service/
│   └── TransferService.java        # Business logic for transfers
├── repository/
│   ├── AccountRepository.java      # Repository for bank accounts
│   ├── TransactionRepository.java  # Repository for transactions
│   └── AuditLogRepository.java     # Repository for audit logs
└── model/
    ├── Account.java                # Bank account entity
    ├── Transaction.java            # Transaction entity
    ├── AuditLog.java               # Audit log entity
    └── TransferResult.java         # Transfer result
```

## Technologies Used

- **Java 17**
- **Spring Boot 3.3.2**
- **Spring Data JPA**
- **PostgreSQL**
- **Maven**

## API Endpoints

### POST /api/seed
Initializes the database with test accounts:
- Account A-001: $100.00
- Account A-002: $50.00

### POST /api/transfer
Performs a transfer between accounts:
- `from`: Source account number
- `to`: Destination account number  
- `amount`: Amount to transfer

## Configuration

The project uses `application.properties` for database configuration and `schema.sql` to create the necessary tables.

## Statement

Complete the TransferService.java to a working solution, matching Fund Transfer System explained 

## Build and Execution

```bash
# Compile the project
mvn clean compile

# Package (without tests)
mvn package -DskipTests

# Run
java -jar target/postgres-transfer-service-0.0.1-SNAPSHOT.jar
```

## Security Features

- **Pessimistic locking** on accounts during transfers
- **Balance validation** before processing
- **Atomic transactions** with automatic rollback
- **Automatic retries** in case of optimistic locking conflicts
- **Complete audit** of all operations

## Database

The schema includes:
- `bank.account`: Bank accounts with version control
- `bank.tx`: Transactions with status and timestamps
- `bank.audit_log`: Audit logs in simple text format
