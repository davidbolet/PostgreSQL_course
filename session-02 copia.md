# Session 2: Schema Design for Microservices

## Duration: 5 hours

---

## 🧠 Objectives

- Understand how to design clean and scalable database schemas.
- Evaluate normalization and denormalization trade-offs.
- Apply foreign key strategies for distributed microservices.
- Learn schema ownership models and design boundaries.
- Identify anti-patterns and best practices in schema design.
- Practice modeling a service schema from scratch.

---

## 1. What Makes a Good Schema?

A well-designed schema:
- Reflects business rules clearly
- Supports scalability and migrations
- Enforces data consistency
- Avoids unnecessary coupling
- Enables efficient querying

Good schema design is the foundation for data integrity and developer productivity.

---

## 2. Normalization vs Denormalization

| Normalization                           | Denormalization                           |
|----------------------------------------|--------------------------------------------|
| Reduces redundancy                     | Reduces joins                               |
| Better write consistency               | Faster read performance                     |
| Fewer update anomalies                 | May introduce inconsistency                 |
| Common for OLTP systems                | Common for OLAP or caching layers           |

Use denormalization when:
- Reads dominate over writes
- Performance justifies redundancy
- You can tolerate some duplication

---

## 3. Foreign Key Strategies in Microservices

### In monoliths:
- Enforced in the database

### In microservices:
- Foreign keys may be dropped at DB level
- Consistency is enforced at the application level
- Avoid tight coupling between services

Patterns:
- Store foreign keys as UUIDs or references
- Validate existence via APIs or background sync
- Use event sourcing or changelogs

---

## 4. Design Patterns for Data Boundaries

- **DB-per-service** (recommended): Each service owns its own schema
- **Shared DB** (anti-pattern): Multiple services query the same database
- **API Composition**: Aggregate data at the API layer
- **CQRS**: Separate read and write models

Use **bounded context** to define logical schema ownership.

---

## 5. Shared vs Private Schemas

| Private Schema             | Shared Schema              |
|----------------------------|----------------------------|
| Owned by one service       | Used by multiple services  |
| Can evolve independently   | Requires coordination      |
| Enforces SRP               | Leads to tight coupling    |
| Easier to test and deploy  | Higher risk of breaking changes |

Recommendation: Always start with private schemas.

---

## 6. Anti-Patterns in Schema Design

- Foreign keys between microservices
- Single table for multiple contexts
- Duplicate data without sync mechanism
- Implicit ownership
- Abusing JSON fields to avoid normalization

---

## 7. Naming Conventions and Consistency

Best practices:
- Use `snake_case` for table and column names
- Prefix with context (e.g., `user_profile`)
- Avoid reserved keywords
- Be consistent in singular/plural use
- Document schema changes (migrations)

Example:

```sql
CREATE TABLE customer_profile (
    customer_id UUID PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);
```

---

## 8. Designing for Scalability and Migration

- Use UUIDs or ULIDs as primary keys for distribution
- Avoid sequential IDs in sharded systems
- Plan for schema migrations using tools like Flyway or Liquibase
- Keep migrations backward-compatible during rollouts

---

## 9. Read/Write Segregation

Use **CQRS** to optimize:

- Separate models for commands (writes) and queries (reads)
- Allows independent scaling
- Improves performance on read-heavy services

---

## 10. Practice: Model the Schema for a Service

### Scenario:

You are designing a **Notification Service** that tracks messages sent to users.

Requirements:
- Store notifications with ID, type (EMAIL, SMS), payload, recipient, sent time, and status
- Each notification belongs to a user
- Must support querying by user and status

### Task:

Model a normalized schema that:
- Defines clear ownership
- Avoids unnecessary joins
- Can evolve independently

Example:

```sql
CREATE TABLE notification (
    id UUID PRIMARY KEY,
    recipient_id UUID NOT NULL,
    type TEXT CHECK (type IN ('EMAIL', 'SMS')),
    payload JSONB NOT NULL,
    status TEXT CHECK (status IN ('PENDING', 'SENT', 'FAILED')),
    sent_at TIMESTAMP
);
```

---

## ✅ Summary

In this session, you:

- Analyzed schema principles for microservice architectures
- Compared normalization and denormalization
- Learned patterns for schema independence and scalability
- Modeled a schema with isolation, flexibility, and readability

Next session: **Normalized Database Design**
