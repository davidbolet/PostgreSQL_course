# Session 4: Query Analysis for Defect Resolution

## Duration: 3 hours

---

## 🧠 Objectives

- Understand how to analyze SQL queries for performance and correctness.
- Identify common query defects and inefficiencies.
- Use PostgreSQL tools to inspect and diagnose query behavior.
- Learn techniques for query rewriting and indexing strategies.
- Practice improving defective queries with measurable improvements.

---

## 1. Introduction to Query Analysis

Query analysis focuses on understanding:

- How a query is executed internally
- How much time and resources it consumes
- Whether indexes are used efficiently
- How the query can be rewritten or improved

---

## 2. Common Query Defects

| Defect Type         | Description                                         |
|---------------------|-----------------------------------------------------|
| N+1 Query Problem   | Multiple subqueries instead of a single join        |
| Cartesian Joins     | Missing join condition, exponential result size     |
| Unindexed Filters   | Full table scans on large datasets                  |
| SELECT * Abuse      | Fetching unnecessary columns                        |
| Overuse of Subqueries | Nested queries that can be flattened              |

---

## 3. PostgreSQL Tools for Analysis

### EXPLAIN

Shows how the planner intends to execute a query.

```sql
EXPLAIN SELECT * FROM orders WHERE customer_id = 42;
```

### EXPLAIN ANALYZE

Executes the query and shows actual performance.

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 42;
```

### pg_stat_statements

Tracks executed queries and performance stats.

Enable with:

```sql
CREATE EXTENSION pg_stat_statements;
```

Query:

```sql
SELECT query, calls, total_time, rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 5;
```

---

## 4. Query Optimization Techniques

- Add indexes to frequently filtered columns
- Use joins over correlated subqueries
- Limit use of complex views
- Fetch only required columns
- Avoid casting in WHERE clause (can skip index)

**Index usage example:**

```sql
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

---

## 5. Practice: Improve a Slow Query

### Initial Query (slow)

```sql
SELECT * FROM orders
WHERE CAST(order_date AS TEXT) LIKE '%2023%';
```

### Problems:
- Cast disables index
- SELECT * fetches unused columns

### Optimized Query:

```sql
SELECT id, customer_id, order_date
FROM orders
WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';
```

Add index if missing:

```sql
CREATE INDEX idx_orders_date ON orders(order_date);
```

---

## 6. Tips for Troubleshooting

- Use `pg_stat_activity` to see current queries
- Watch for long-running queries and locks
- Monitor query plans regularly
- Schedule `ANALYZE` or enable autovacuum
- Use connection poolers to control parallel load

---

## ✅ Summary

In this session, you:

- Learned to identify performance defects in queries
- Used EXPLAIN, ANALYZE, and pg_stat_statements
- Optimized and rewrote slow queries
- Understood how to diagnose query performance in real-world scenarios

Next session: **Working with Transactions**
