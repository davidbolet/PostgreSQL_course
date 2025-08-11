# Exercise: Build a PostgreSQL Image with Custom Configuration

**Estimated time:** 60-75 min  
**Format:** Small teams (2–3 students)  
**Goal:** Build and run a Docker image of PostgreSQL based on the official image, using your own `postgresql.conf` and local folders for persistent storage.

---

## 🎯 Learning objectives
- Understand PostgreSQL **startup & configuration** flow in Docker.
- Apply changes in `postgresql.conf` and **verify** them with `psql`.
- Configure **volumes** so data persists across restarts.
- Practice **basic Docker** and **psql** commands.

---

## ✅ Acceptance criteria
- The image **builds** without errors.
- The container **runs** and is reachable at `localhost:5432`.
- The server **applies** parameters from your `postgresql.conf` (e.g., `SHOW shared_buffers;`).
- Data **persists** after restarting the container.

---

## 🧰 Prerequisites
- Docker Desktop / Docker Engine installed.
- A code editor (VS Code, etc.).
- `psql` client (from host or via `docker exec`).

---

## 📁 Recommended folder structure
```
custom-postgres/
├─ Dockerfile
├─ postgresql.conf
└─ data/               # host volume mapped to /var/lib/postgresql/data
```

---

## 🧩 Step 1 — Create a baseline `postgresql.conf`
Create `postgresql.conf` with safe lab values:

```conf
# postgresql.conf (example)
max_connections = 120
shared_buffers  = 512MB
work_mem        = 8MB
maintenance_work_mem = 256MB

# WAL & replication (optional for labs)
wal_level       = logical
synchronous_commit = on

# Autovacuum (keep enabled; tune if needed)
autovacuum = on
```

> 💡 Tip: These values are **examples**. In production you size them according to RAM, CPU and workload.

---

## 🧱 Step 2 — Create the `Dockerfile`
Create `Dockerfile` in the same folder:
```dockerfile
FROM postgres:15

# Copy your custom configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Initial user/DB
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=admin
ENV POSTGRES_DB=myapp

# Start postgres with your config file
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
```

---

## 🏗️ Step 3 — Build the image
Run from `custom-postgres/`:

```bash
docker build -t custom-postgres .
```

---

## ▶️ Step 4 — Run the container with volume and port mapping
### macOS/Linux (bash/zsh)
```bash
docker run -d --name pg-custom   -p 5432:5432   -v "$(pwd)/data:/var/lib/postgresql/data"   custom-postgres
```

### Windows (PowerShell)
```powershell
docker run -d --name pg-custom   -p 5432:5432   -v ${PWD}\data:/var/lib/postgresql/data   custom-postgres
```

> 🧪 Verify the container is healthy:
```bash
docker ps --filter "name=pg-custom"
docker logs pg-custom --tail=50
```

---

## 🔍 Step 5 — Verify the applied configuration
Connect with `psql` (pick one):

**A) From host (if you have psql installed):**
```bash
psql -h localhost -U admin -d myapp
```

**B) From inside the container:**
```bash
docker exec -it pg-custom psql -U admin -d myapp
```

Inside `psql`, run:
```sql
SHOW shared_buffers;
SHOW work_mem;
SHOW wal_level;
SHOW max_connections;
```
> They should match your custom `postgresql.conf` values.

---

## 💾 Step 6 — Test data persistence
In `psql`:
```sql
CREATE TABLE test_persist (id int primary key, note text);
INSERT INTO test_persist VALUES (1, 'hello');
SELECT * FROM test_persist;
```

Restart the container and query again:
```bash
docker restart pg-custom
```

In `psql` (again):
```sql
SELECT * FROM test_persist;
```
> You should still see the row you inserted. If not, check the **volume mapping**.

---

## 🧪 Step 7 — (Optional) Tweak and verify
- Change `shared_buffers` or `work_mem` in `postgresql.conf`.
- Restart the container:
```bash
docker restart pg-custom
```
- Verify again with `SHOW ...;` in `psql`.

---

## 🧹 Step 8 — Cleanup (if you want to reset the lab)
```bash
docker rm -f pg-custom
docker rmi custom-postgres
# (optional) wipe local volume data
rm -rf ./data/*
```

---

## 🧯 Troubleshooting
- **Port 5432 already in use**  
  - See which process: `lsof -i :5432` (macOS/Linux) or `netstat -a -n -o | findstr 5432` (Windows).  
  - Change mapping to `-p 5433:5432` and connect with `-h localhost -p 5433`.
- **Permissions/SELinux on Linux**: you may need `:Z`  
  `-v "$(pwd)/data:/var/lib/postgresql/data:Z"`
- **psql won’t connect**: check `docker logs pg-custom` and your `POSTGRES_...` variables.
- **Config not applied**: confirm the `CMD` path and that the file exists inside the container:  
  `docker exec -it pg-custom ls -l /etc/postgresql/postgresql.conf`

---

## 📦 Next commands (to continue after verification)
Run these **after** you’ve completed the basic verification:

1) **Create an extra role and database**
```sql
CREATE ROLE app_user LOGIN PASSWORD 'app_pwd';
CREATE DATABASE appdb OWNER app_user;
GRANT ALL PRIVILEGES ON DATABASE appdb TO app_user;
```

2) **Enable a useful extension for query stats**
```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

3) **Create an index and test a query**
```sql
CREATE TABLE items (id serial PRIMARY KEY, sku text, created_at timestamptz default now());
CREATE INDEX idx_items_sku ON items(sku);
INSERT INTO items (sku) SELECT 'SKU-' || g FROM generate_series(1, 10000) g;
EXPLAIN ANALYZE SELECT * FROM items WHERE sku = 'SKU-5000';
```

4) **Check activity statistics**
```sql
SELECT pid, usename, state, query
FROM pg_stat_activity
ORDER BY (state='active') DESC, pid
LIMIT 10;
```

5) **(Optional) Connect with a GUI client**
- pgAdmin / DBeaver / TablePlus / Beekeeper Studio  
Connect to `localhost:5432`, user `admin`, DB `myapp`.

---

### ✅ Team deliverables
- `Dockerfile`, `postgresql.conf`, and a short **README** with reproducible steps.
- Proof that config was applied (`SHOW shared_buffers;`) and that data persists after restart.
- 2–3 sentences justifying **one** config change you chose (and why).
