# PostgreSQL Lab: Enabling `pg_stat_statements` and `auto_explain`

In this lab, you will configure PostgreSQL to load two powerful diagnostic modules:

- **pg_stat_statements**: tracks execution statistics of all SQL statements.
- **auto_explain**: automatically logs execution plans for slow queries.

These modules must be loaded via `shared_preload_libraries`, which requires a server restart.

---

## 1. Local Installation (Linux / macOS / Windows)

### Step 1. Find your configuration file
Run inside `psql`:
```sql
SHOW config_file;
```

### Step 2. Edit `postgresql.conf`
Locate the line:
```conf
#shared_preload_libraries = ''
```
Change it to:
```conf
shared_preload_libraries = 'pg_stat_statements,auto_explain'
```

### Step 3. Restart PostgreSQL
- Linux (systemd):
  ```bash
  sudo systemctl restart postgresql
  ```
- macOS (Homebrew):
  ```bash
  brew services restart postgresql
  ```
- Windows:
  Restart the PostgreSQL service from **Services.msc**.

### Step 4. Enable extensions
In each database where you want to use them:
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS auto_explain;
```

---

## 2. Docker Installation

If you run PostgreSQL with Docker, you must pass the parameter at container startup.

Example:
```bash
docker run -d   --name postgres16   -e POSTGRES_PASSWORD=postgres   -v pgdata:/var/lib/postgresql/data   -p 5432:5432   postgres:16   -c shared_preload_libraries=pg_stat_statements,auto_explain
```

Then, inside the container (or via `psql`):
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS auto_explain;
```

---

## 3. Verifying the Setup

### Check that libraries are loaded:
```sql
SHOW shared_preload_libraries;
```
Expected output should include:
```
pg_stat_statements, auto_explain
```

### Check that the extensions are installed:
```sql
\dx
```
Look for:
```
pg_stat_statements
auto_explain
```

---

## ✅ Lab Completion

You have successfully:
- Loaded `pg_stat_statements` and `auto_explain` into PostgreSQL.
- Restarted PostgreSQL with the new configuration.
- Verified that both extensions are active.
