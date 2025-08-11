# Hands‑on Exercise — Users & Roles in PostgreSQL (45–60 min)

**Goal:** Implement least‑privilege access for a simple app: separate **owner (DDL)** from **runtime user (DML)**, add a **read‑only group**, and verify privileges.

## 0) Setup
Connect as a superuser (or a role with enough rights):
```sql
CREATE ROLE app_owner LOGIN PASSWORD 'owner_pwd';
CREATE ROLE app_user  LOGIN PASSWORD 'user_pwd';
CREATE ROLE app_readonly NOLOGIN;  -- group role
CREATE DATABASE myapp;
\c myapp
```

## 1) Create schema and baseline grants
```sql
CREATE SCHEMA app AUTHORIZATION app_owner;

-- Optional hardening
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL   ON DATABASE myapp  FROM PUBLIC;

-- App user can use the schema; owner can do DDL
GRANT USAGE ON SCHEMA app TO app_user;
GRANT CREATE ON SCHEMA app TO app_owner;
```

## 2) Default privileges for future objects
Ensure objects created by **app_owner** are usable by **app_user**:
```sql
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;

ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO app_user;
```

## 3) Create a table as the owner; test as the user
```sql
SET ROLE app_owner;
CREATE TABLE app.customers (
  customer_id BIGSERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  email       TEXT UNIQUE
);
RESET ROLE;

-- Test DML as app_user
SET ROLE app_user;
INSERT INTO app.customers (name, email) VALUES ('Ada Lovelace','ada@example.com');
SELECT * FROM app.customers;
RESET ROLE;
```

**Check your work**
```sql
\dp app.*     -- table/sequence privileges
\ddp          -- default privileges
\du           -- roles
```

## 4) Add a read‑only path
Grant the **app_readonly** group select access, then assign membership:
```sql
GRANT SELECT ON ALL TABLES IN SCHEMA app TO app_readonly;
GRANT USAGE  ON SCHEMA app TO app_readonly;

-- New tables (created by app_owner) will also be readable
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
GRANT SELECT ON TABLES TO app_readonly;

-- Enroll a user into the read-only group (could be an intern account)
GRANT app_readonly TO app_user;
```

**Verify**
```sql
SET ROLE app_user;
SELECT * FROM app.customers;  -- should work via direct grants and/or group
RESET ROLE;
```

## 5) Challenge (optional)
1. Create another user `report_user` (LOGIN) and grant only **read‑only** access via `app_readonly`.  
2. Add a second table `app.orders` as `app_owner`. Verify both `app_user` and `report_user` can read it **without extra GRANTs** (thanks to **ALTER DEFAULT PRIVILEGES**).  
3. Revoke `INSERT` from `app_user` and confirm `INSERT` fails but `SELECT` still works.

**Hints**
```sql
CREATE ROLE report_user LOGIN PASSWORD 'report_pwd';
GRANT app_readonly TO report_user;

SET ROLE app_owner;
CREATE TABLE app.orders (
  order_id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT REFERENCES app.customers(customer_id),
  total NUMERIC(10,2) NOT NULL CHECK (total >= 0)
);
RESET ROLE;

REVOKE INSERT ON ALL TABLES IN SCHEMA app FROM app_user;
```

## 6) Cleanup (optional)
```sql
\c postgres
DROP DATABASE myapp WITH (FORCE);
DROP ROLE IF EXISTS report_user;
DROP ROLE IF EXISTS app_user;
DROP ROLE IF EXISTS app_owner;
DROP ROLE IF EXISTS app_readonly;
```

---

### Submission
- Paste the output of `\dp app.*` and `\ddp`.
- Include the SQL you ran.
- 2–3 sentences: explain **how default privileges** helped avoid repetitive GRANTs.
