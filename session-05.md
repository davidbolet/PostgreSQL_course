# Session 5: Working with Transactions

## Duration: 3 hours

---

## 🧠 Objectives

- Master transactional behavior in PostgreSQL.
- Understand savepoints and nested transactions.
- Compare isolation levels and concurrency control models.
- Detect and troubleshoot deadlocks.
- Use PostgreSQL tools to monitor and diagnose transactions.
- Practice building a multi-step transactional workflow.

---

## 1. Transaction Basics

PostgreSQL supports ACID-compliant transactions.

### Key Commands

```sql
BEGIN;
-- your SQL statements
COMMIT;  -- or ROLLBACK;
```

### Auto-commit

In `psql`, each statement is auto-committed unless explicitly wrapped in a transaction block.

---

## 2. Savepoints and Nested Transactions

Use `SAVEPOINT` to mark a rollback point:

```sql
BEGIN;
INSERT INTO payments ...;

SAVEPOINT partial;

UPDATE accounts ...;

ROLLBACK TO partial; -- undo UPDATE but keep INSERT

COMMIT;
```

Nested transactions are simulated using savepoints.

---

## 3. Isolation Levels

| Isolation Level       | Description                                   |
|------------------------|-----------------------------------------------|
| Read Committed (default) | Reads only committed rows                   |
| Repeatable Read       | Guarantees same results within the transaction |
| Serializable          | Fully ACID, may cause serialization errors     |

Set isolation level:

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
```

---

## 4. Locking: Row vs Table

- Row-level: for individual rows (via SELECT ... FOR UPDATE)
- Table-level: for schema modifications or explicit locks

```sql
SELECT * FROM users WHERE id = 1 FOR UPDATE;
```

View locks:

```sql
SELECT * FROM pg_locks;
```

---

## 5. Concurrency Control

### Optimistic

- Assume no conflict, check before commit
- Good for low contention systems

### Pessimistic

- Lock data early to avoid conflicts
- Use `FOR UPDATE` or transactions

---

## 6. Deadlocks and Detection

Occurs when two transactions wait on each other.

PostgreSQL detects and aborts one with:

```
ERROR: deadlock detected
```

Use logs and `pg_stat_activity` to trace:

```sql
SELECT * FROM pg_stat_activity;
```

---

## 7. Performance vs Isolation

| Isolation Level  | Performance | Consistency |
|------------------|-------------|-------------|
| Read Committed   | Fastest     | Lower       |
| Repeatable Read  | Moderate    | High        |
| Serializable     | Slowest     | Strictest   |

Choose based on use case and risk tolerance.

---

## 8. Practice: Multi-Step Transaction Workflow

### Scenario

A `transfer_funds` procedure:

1. Check sender balance
2. Deduct amount
3. Credit recipient
4. Insert audit log
5. Commit all changes

### SQL Template

```sql
BEGIN;

-- 1. Check balance
SELECT balance INTO sender_balance FROM accounts WHERE id = 1;

-- 2. Deduct
UPDATE accounts SET balance = balance - 100 WHERE id = 1;

-- 3. Credit
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- 4. Log
INSERT INTO transactions (sender_id, receiver_id, amount) VALUES (1, 2, 100);

COMMIT;
```

Add SAVEPOINT before each step to allow partial rollbacks.

---

## ✅ Summary

In this session, you:

- Managed transactions using BEGIN, COMMIT, and ROLLBACK
- Used savepoints to structure transaction logic
- Explored PostgreSQL isolation levels and locking behavior
- Detected and diagnosed deadlocks
- Built a robust multi-step transaction

Next session: **Redis and Spring Boot Integration**
