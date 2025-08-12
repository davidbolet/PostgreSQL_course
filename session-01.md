# Session 1: Foundations of PostgreSQL

## Duration: 5 hours

---

## 🧠 Objectives

- Core concepts overview
- Understand PostgreSQL architecture and internal processes.
- Explore configuration options and tuning techniques.
- Compare PostgreSQL and MySQL in distributed setups.
- Learn about ACID properties and their implementation in PostgreSQL.
- Learn about users and roles in postgres.
- Use PostgreSQL CLI tools and Docker for practical setup.
- Learn different ways to connect to PostgreSQL from java.

---

## 0. Core concepts overview

---

## 1. PostgreSQL Architecture Overview

PostgreSQL is a multi-process database system designed for reliability and extensibility.

### Key Components

- **Postmaster**: Parent process managing all child processes.
- **Background Writer**: Writes dirty buffers to disk.
- **Checkpointer**: Flushes changes at checkpoints.
- **WAL Writer**: Persists write-ahead logs for durability.
- **Autovacuum Daemon**: Cleans up dead rows and maintains statistics.

---

## 2. Key Processes and Responsibilities

| Process           | Description                             |
|-------------------|-----------------------------------------|
| Checkpointer      | Forces periodic writes to disk          |
| WAL Writer        | Persists transaction logs               |
| Background Writer | Writes shared buffer changes            |
| Autovacuum        | Prevents table bloat                    |
| Stats Collector   | Gathers internal metrics                |

---

## 3. PostgreSQL vs MySQL in Distributed Systems

| Feature               | PostgreSQL                      | MySQL                         |
|------------------------|----------------------------------|-------------------------------|
| MVCC                  | Native and robust               | Engine-dependent              |
| JSONB Support         | Full indexing and search        | Limited features              |
| Stored Procedures     | PL/pgSQL and others             | Basic support                 |
| Partitioning          | Native and flexible              | Less flexible                 |
| Replication           | Streaming, logical               | Binary, semi-sync             |

---

## 4. ACID Properties in PostgreSQL

PostgreSQL is fully ACID-compliant:

- **Atomicity**: All or nothing via transaction control.
- **Consistency**: Enforced through constraints and triggers.
- **Isolation**: Controlled via isolation levels.
- **Durability**: Ensured with WAL and checkpointing.

---

## 5. Configuration Overview and practice

The file `postgresql.conf` controls server behavior.

### Examples of parameters:

```conf
shared_buffers = 256MB
work_mem = 4MB
maintenance_work_mem = 64MB
max_connections = 100
wal_level = replica
```

Use tools like [pgtune](https://pgtune.leopard.in.ua/) to calculate ideal values based on system specs.

[Practice statement](exercise-custom-postgres-image.md) 

---

## 6. Users and Roles in PostgreSQL

-	Roles vs users, login/no-login, inheritance, group roles
-	Privileges & scopes (DB/SCHEMA/TABLE/SEQUENCE), GRANT/REVOKE, ALTER DEFAULT PRIVILEGES
-	psql shortcuts: \du, \dg, \dp
-	Quick lab: [secure a schema for an app owner vs app user](exercise-users-and-roles.md) 


## 7. psql CLI and Automation

`psql` is PostgreSQL’s interactive terminal.

### Basic commands:

```bash
psql -U postgres
```

Inside `psql`:

- `\l` – list databases
- `\dt` – list tables
- `\d table_name` – describe table
- `\q` – quit

### Automate with scripts:

```bash
psql -U postgres -d mydb -f init.sql
```

Use `.psqlrc` for preconfigured settings.

---

## 8. Connecting from Java and introducing JSONB

[Guide to Java drivers](postgres-java-drivers.md)
[Lab: Connection types](lab-connection-types.md)
[Lab: Introduction to JSONB](lab-jsonb.md)

---

## 9. Recommended Client Tools

| Tool               | Type      | Notes                            |
|--------------------|-----------|----------------------------------|
| pgAdmin            | GUI       | Official PostgreSQL admin tool   |
| DBVisualizer       | GUI       | Multi-database, free version     |
| DBeaver            | GUI       | Multi-database, open-source      |
| DataGrip           | IDE       | JetBrains commercial tool        |
| TablePlus          | GUI       | Lightweight, fast, user-friendly |
| psql               | CLI       | Default PostgreSQL terminal      |
| Beekeeper Studio   | GUI       | Open-source, modern interface    |

---

## ✅ Summary

In this session, you:

- Understood PostgreSQL architecture and core processes
- Compared PostgreSQL and MySQL in distributed systems
- Explored ACID compliance and PostgreSQL configuration
- Built a custom Docker-based PostgreSQL instance
- Reviewed client tools for interaction and debugging

Next session: **Schema Design for Microservices**
