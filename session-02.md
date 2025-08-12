# Session 2: Normalized Database Design

## Duration: 5 hours

---

## 🧠 Objectives

- Understand the goals of database normalization.
- Learn how to apply 1NF, 2NF, 3NF, and BCNF.
- Explore the benefits and trade-offs of normalization.
- Practice designing normalized schemas.
- Identify and correct normalization issues in real scenarios.
- Learn what is JSONB and when is it worth using it.

---

## 1. What is Database Normalization?

Normalization is the process of organizing data in a database to:

- Eliminate redundancy
- Ensure data integrity
- Simplify maintenance
- Improve consistency

The process involves applying a series of normal forms (rules).

---

## 2. First Normal Form (1NF)

**Requirements:**
- All columns contain atomic (indivisible) values.
- No repeating groups or arrays.

**Violation Example:**

```sql
CREATE TABLE student (
    id SERIAL PRIMARY KEY,
    name TEXT,
    subjects TEXT[] -- violates 1NF
);
```

**Normalized:**

```sql
CREATE TABLE subject (
    student_id INT,
    subject_name TEXT,
    PRIMARY KEY (student_id, subject_name)
);
```

---

## 3. Second Normal Form (2NF)

**Requirements:**
- Meet all 1NF rules.
- Remove partial dependencies from composite primary keys.

**Violation Example:**

```sql
CREATE TABLE enrollment (
    student_id INT,
    course_id INT,
    student_name TEXT, -- depends only on student_id
    PRIMARY KEY (student_id, course_id)
);
```

**Normalized:**

```sql
CREATE TABLE student (
    student_id INT PRIMARY KEY,
    student_name TEXT
);

CREATE TABLE enrollment (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id)
);
```

---

## 4. Third Normal Form (3NF)

**Requirements:**
- Meet all 2NF rules.
- No transitive dependencies (non-key attribute depends on another non-key attribute).

**Violation Example:**

```sql
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name TEXT,
    department_id INT,
    department_name TEXT -- transitive dependency
);
```

**Normalized:**

```sql
CREATE TABLE departments (
    id INT PRIMARY KEY,
    name TEXT
);

CREATE TABLE employees (
    id INT PRIMARY KEY,
    name TEXT,
    department_id INT REFERENCES departments(id)
);
```

---

## 5. Boyce-Codd Normal Form (BCNF)

Stricter than 3NF. Every determinant must be a candidate key.

**Use case:** when there are multiple composite candidate keys.

---

## 6. Benefits of Normalization

- Prevents data anomalies (update, delete, insert)
- Ensures referential integrity
- Saves space by reducing duplication
- Makes data easier to query and maintain

---

## 7. When Not to Normalize (Fully)

- For reporting/analytics (OLAP) → denormalization can improve performance
- For heavy-read use cases → balance joins vs redundancy
- For cache systems → flattened documents may be preferred

---

## 8. Practice: Normalize a Problematic Schema

### Given:

```sql
CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_name TEXT,
    customer_email TEXT,
    item_name TEXT,
    item_price DECIMAL
);
```

### Normalize to 3NF:

```sql
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT
);

CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    name TEXT,
    price DECIMAL
);

CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    item_id INT REFERENCES items(id)
);
```

---

## ✅ Summary

In this session, you:

- Learned and applied 1NF, 2NF, 3NF, and BCNF
- Designed normalized schemas to eliminate redundancy
- Saw where normalization helps and where denormalization is preferable
- Practiced converting flat structures into normalized forms

Next session: **Query Analysis for Defect Resolution**
