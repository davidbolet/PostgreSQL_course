# RedisInsight + Docker on macOS — Build, Run, and Connect to Local Redis

This guide shows how to **create a Dockerfile for RedisInsight**, run it, and **connect to a Redis server on your Mac**.

> Works on macOS (Apple Silicon or Intel). On macOS, containers reach the host using `host.docker.internal` (not `127.0.0.1`).

---

## 1) Create the Dockerfile

Create a folder (e.g., `redisinsight/`) and add a `Dockerfile`:

```dockerfile
# redisinsight/Dockerfile
FROM redis/redisinsight:latest

# Optional: auto-accept terms (use only if appropriate for your environment)
ENV RI_ACCEPT_TERMS_AND_CONDITIONS=yes

# Persist app data (saved connections, settings)
VOLUME ["/data"]

# UI listens on 5540 inside the container
EXPOSE 5540
```

> Note: You could also run the official image directly with `docker run ...` (see below). The Dockerfile is helpful if you want to bake in defaults or extensions later.

---

## 2) Build a local image

```bash
cd redisinsight
docker build -t redisinsight-local .
```

If you run into architecture issues on Apple Silicon (rare), add:
```bash
docker build --platform linux/amd64 -t redisinsight-local .
```

---

## 3) Run RedisInsight (with persistence)

Create a Docker volume to persist RedisInsight’s data:

```bash
docker volume create redisinsight-data
```

Run the container:

```bash
docker run -d --name redisinsight \
  -p 5540:5540 \
  -v redisinsight-data:/data \
  redisinsight-local
```

Open the UI at **http://localhost:5540**.

> **Alternative without building** (directly from the official image):
> ```bash
> docker run -d --name redisinsight \
>   -p 5540:5540 \
>   -v redisinsight-data:/data \
>   -e RI_ACCEPT_TERMS_AND_CONDITIONS=yes \
>   redis/redisinsight:latest
> ```

---

## 4) Connect RedisInsight to **Redis running on your Mac**

When adding a database in RedisInsight:
- **Host:** `host.docker.internal`
- **Port:** `6379` (or your Redis port)
- **Password:** your password if Redis auth is enabled

Why not `127.0.0.1`? Inside a container, `127.0.0.1` means the **container itself**, not your Mac. On macOS, Docker provides the special hostname `host.docker.internal` to reach the host.

### Quick connectivity test (from a throwaway container)
```bash
docker run --rm -it redis:7-alpine \
  redis-cli -h host.docker.internal -p 6379 PING
# Expect: PONG
```

---

## 5) (Optional) If Redis runs in **another container**

Put both containers on the same network and connect by **container name**:

```bash
docker network create devnet

# Redis server
docker run -d --name redis --network devnet -p 6379:6379 redis:7-alpine

# RedisInsight
docker run -d --name redisinsight --network devnet \
  -p 5540:5540 -v redisinsight-data:/data \
  redis/redisinsight:latest
```

In RedisInsight use:
- **Host:** `redis`
- **Port:** `6379`

---

## 6) Docker Compose example (Redis + RedisInsight)

Create `compose.yaml` in a folder and run `docker compose up -d`:

```yaml
services:
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
    command: ["redis-server", "--appendonly", "yes"]

  redisinsight:
    image: redis/redisinsight:latest
    ports: ["5540:5540"]
    volumes: ["redisinsight:/data"]
    environment:
      RI_ACCEPT_TERMS_AND_CONDITIONS: "yes"

volumes:
  redisinsight:
```

Open **http://localhost:5540** and add the DB:
- If Redis is the container above → **Host** `redis`
- If Redis is on your Mac → **Host** `host.docker.internal`

---

## 7) Troubleshooting

- **Can’t connect on 127.0.0.1**  
  Use `host.docker.internal` on macOS/Windows; `127.0.0.1` is the container’s loopback.

- **Port busy**  
  Change the published port, e.g. `-p 8001:5540` and open `http://localhost:8001`.

- **Auth/TLS**  
  If Redis requires a password, enter it in RedisInsight’s connection form. For TLS, configure the TLS options there.

- **Verify Redis is reachable from your Mac**  
  ```bash
  redis-cli -h 127.0.0.1 -p 6379 PING  # expect PONG
  ```

- **Verify from a container**  
  ```bash
  docker run --rm -it redis:7-alpine \
    redis-cli -h host.docker.internal -p 6379 PING
  ```

- **Container logs**  
  ```bash
  docker logs redisinsight
  ```
