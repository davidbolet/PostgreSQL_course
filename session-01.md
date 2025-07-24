# Session 1: Foundations of PostgreSQL

## Duration: 5 hours

---

## 🧠 Objectives

- Understand PostgreSQL architecture and internal processes.
- Explore configuration options and tuning techniques.
- Compare PostgreSQL and MySQL in distributed setups.
- Learn about ACID properties and their implementation in PostgreSQL.
- Use PostgreSQL CLI tools and Docker for practical setup.

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

## 5. Configuration Overview

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

---

## 6. psql CLI and Automation

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

## 7. Practice: Custom Docker Image with PostgreSQL

### Goal

Create a Docker image based on the official PostgreSQL image that:

- Includes a custom `postgresql.conf`
- Mounts local folders for data
- Pre-configures the DB user and database

### Folder structure:

```
custom-postgres/
├── Dockerfile
├── postgresql.conf
└── data/  # for persistent volume
```

### postgresql.conf (example)

```conf
max_connections = 150
shared_buffers = 512MB
work_mem = 8MB
wal_level = logical
```

### Dockerfile

```dockerfile
FROM postgres:15

COPY postgresql.conf /etc/postgresql/postgresql.conf

ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=admin
ENV POSTGRES_DB=myapp

CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
```

### Run:

```bash
docker build -t custom-postgres .
docker run -d \
  -v $(pwd)/data:/var/lib/postgresql/data \
  -p 5432:5432 custom-postgres
```

---

## 8. Recommended Client Tools

| Tool               | Type      | Notes                            |
|--------------------|-----------|----------------------------------|
| pgAdmin            | GUI       | Official PostgreSQL admin tool   |
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
