# PostgreSQL Configuration Cheat Sheet (Focused Parameters)

Below are concise, practical explanations of each parameter, including what it controls, what your current value implies, and tuning tips.

```conf
max_connections = 100
shared_buffers = 1GB
effective_cache_size = 3GB
maintenance_work_mem = 256MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 4
effective_io_concurrency = 2
work_mem = 4854kB
huge_pages = off
min_wal_size = 1GB
max_wal_size = 4GB
```

---

## max_connections = 100
**What it is:** Maximum concurrent database sessions.  
**Implications:** Higher values increase memory usage and contention. Pooling can reduce needed connections.  
**Tuning tips:** Keep modest (e.g., 100–300) and use PgBouncer. Grow only if truly needed and RAM allows.

---

## shared_buffers = 1GB
**What it is:** Memory PostgreSQL uses for its own buffer cache.  
**Implications:** Bigger cache usually means fewer disk reads, but more I/O during checkpoints.  
**Tuning tips:** Often set to ~20–25% of RAM on Linux DB-only hosts. 1GB is a safe, middle-ground value.

---

## effective_cache_size = 3GB
**What it is:** *Planner hint* for how much file-system cache is typically available (OS cache + shared_buffers). No memory is reserved.  
**Implications:** Larger values make index scans more attractive in plans.  
**Tuning tips:** Set to what’s realistically available most of the time (commonly 50–75% of RAM on a DB-only server).

---

## maintenance_work_mem = 256MB
**What it is:** Memory per maintenance task (VACUUM, CREATE INDEX, ALTER TABLE, etc.). Autovacuum uses `autovacuum_work_mem` if set.  
**Implications:** Bigger is faster for index builds and vacuum, but each concurrent task can consume this amount.  
**Tuning tips:** 128–1,024MB depending on workload and concurrency. Temporarily increase for bulk operations.

---

## checkpoint_completion_target = 0.9
**What it is:** Fraction of the checkpoint interval over which writes are spread.  
**Implications:** Higher values smooth I/O and reduce spikes at checkpoint time.  
**Tuning tips:** 0.7–0.9 is common on busy systems. Pair with a sufficiently large `max_wal_size`.

---

## wal_buffers = 16MB
**What it is:** In-memory buffers for WAL (Write-Ahead Log) before flushing to disk.  
**Implications:** Too small can cause WAL write lock contention; too large wastes RAM.  
**Tuning tips:** Auto-tuning works well in recent PG; 16MB is fine for moderate write rates. Increase if you observe WALWriteLock contention.

---

## default_statistics_target = 100
**What it is:** Global target for ANALYZE detail (histograms/MCVs).  
**Implications:** Higher values improve plans for skewed data but cost more time/space for stats.  
**Tuning tips:** Leave at 100 globally. For problematic columns, override per-column (e.g., 200–500).

---

## random_page_cost = 4
**What it is:** Planner cost of random I/O relative to sequential (seq_page_cost = 1).  
**Implications:** Lower values make index scans more likely.  
**Tuning tips:** 4 suits HDDs. On SSD/NVMe, try 1.1–1.5 and verify with `EXPLAIN (ANALYZE, BUFFERS)`.

---

## effective_io_concurrency = 2
**What it is:** Number of asynchronous prefetch requests the planner assumes for bitmap heap scans.  
**Implications:** Higher can accelerate large bitmap scans on storage that handles parallel I/O well.  
**Tuning tips:** 2 is conservative. On modern Linux + SSD, 32–256 is common. Test and monitor I/O.

---

## work_mem = 4854kB
**What it is:** Memory per sort/hash operation (per node, per query, per backend).  
**Implications:** If too small, sorts spill to disk; if too large, many concurrent sorts can exhaust RAM.  
**Tuning tips:** Size for *peak concurrency*. For analytics with few concurrent queries, raise (e.g., 16–64MB). For high OLTP concurrency, keep modest and use per-session overrides when needed.

> **Rule of thumb for RAM budget**  
> `Total peak ≈ shared_buffers + Σ(active backends × avg sort/hash ops × work_mem) + maintenance/autovacuum + OS headroom`

---

## huge_pages = off
**What it is:** Use OS Huge Pages for shared memory (Linux).  
**Implications:** Can reduce TLB misses and improve stability for large shared memory allocations, but requires OS setup.  
**Tuning tips:** With small-to-mid shared memory, `off` is fine. For large instances, consider `try` or `on` plus proper OS configuration (and disable THP).

---

## min_wal_size = 1GB
**What it is:** Lower bound for WAL recycling after checkpoints.  
**Implications:** Prevents churn of WAL segments by keeping at least this much around.  
**Tuning tips:** Set a healthy floor (e.g., 2–8GB) on busy systems to reduce segment creation churn.

---

## max_wal_size = 4GB
**What it is:** Upper bound of WAL generated between checkpoints.  
**Implications:** Larger value means fewer checkpoints and smoother write I/O at the cost of more disk for WAL.  
**Tuning tips:** For heavier write workloads, 8–32GB is common. Monitor checkpoints and I/O latency to guide sizing.

---

### Quick Checks
- **Concurrency vs RAM:** Keep `max_connections` modest; prefer pooling.  
- **Caching Coherence:** `effective_cache_size` should reflect OS cache + `shared_buffers`.  
- **I/O Smoothness:** `checkpoint_completion_target` and `max_wal_size` work together—raise `max_wal_size` if checkpoints are frequent.  
- **Storage Type:** On SSD/NVMe, consider reducing `random_page_cost` and increasing `effective_io_concurrency`.

