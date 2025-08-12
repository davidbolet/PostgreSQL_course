# BCNF Mini-Lab (Boyce–Codd Normal Form)

**Goal:** Practice spotting when a relation is **3NF but not BCNF**, and decompose it to BCNF with a **lossless join**. You will also demonstrate how the decomposition removes **update anomalies**.

## Quick recap
- **3NF:** allows a dependency `X → Y` if `Y` is *prime* (part of some key), even when `X` is not a key.
- **BCNF:** stricter—**every** non-trivial dependency `X → Y` must have `X` as a **superkey**.

Result: Some 3NF schemas still suffer update anomalies; BCNF fixes them.

---

## Setup
Load the seed data (two scenarios):
```sql
\i 01_bcnf_lab_seed.sql
```

You get two relations that are **3NF but NOT BCNF**:

1) `bcnflab.teaches(student, course, professor)`  
   FDs: `(student, course) → professor`, `professor → course` (violates BCNF).  
   Candidate keys: `{student, course}`, `{student, professor}`.

2) `bcnflab.runs(train_no, route, driver)`  
   FDs: `(train_no, route) → driver`, `driver → route` (violates BCNF).  
   Candidate keys: `{train_no, route}`, `{train_no, driver}`.

---

## Your tasks

### Task A — Teaches
1. **Propose a BCNF decomposition.** Hint: isolate the FD `professor → course`.
2. **Create tables** (with sensible PKs/FKs) and **migrate data** from `bcnflab.teaches`.
3. **Prove a lossless join** by reconstructing the original rows (use `EXCEPT`).
4. **Demonstrate the update anomaly is fixed:** change a professor’s course with **one UPDATE**.

### Task B — Runs
1. **Propose a BCNF decomposition.** Hint: isolate the FD `driver → route`.
2. **Create tables** and **migrate data** from `bcnflab.runs`.
3. **Prove a lossless join** and show that “a driver changing routes” is now **one UPDATE**.

---

## Deliverables
- DDL for decomposed tables in each task.
- `INSERT … SELECT` migration queries.
- Validation queries:
  - Row-count equality (`COUNT(*)`) before/after.
  - Exact set equality using `EXCEPT`.
- A short note: *why the determinant is not a key*, and *which table now “owns” that fact*.

## Hints
- A common BCNF decomposition for **Teaches** is:
  - `prof_course(professor PK, course)` and `enrollment(student, professor)`.
- For **Runs**:
  - `driver_route(driver PK, route)` and `assignments(train_no, driver)`.
- Wrap your migration in a transaction: `BEGIN; … COMMIT;`.
- Postgres doesn’t auto-create indexes on FKs—add them if you’ll join a lot.

## Optional stretch
- Add **ON UPDATE CASCADE** to the FK that references the determinant (e.g., `professor`) and try a key change.
- Add a **UNIQUE** constraint if your business rules require it (e.g., `course` unique across professors).

Good luck!
