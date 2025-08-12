# PostgreSQL Java Drivers — A Practical Guide

This guide covers the PostgreSQL Java driver landscape (**JDBC vs R2DBC**), configuration, pooling, transactions and batching, streaming, data types (JSONB, arrays, UUID), **COPY/large objects**, security, performance, testing & migrations, and common gotchas. It includes runnable snippets and lab exercises.

## 1) Driver landscape (what to use when)

**JDBC (pgjdbc)** — classic, blocking I/O  
- Maven: `org.postgresql:postgresql`  
- Works with JPA/Hibernate, Spring Data JPA, MyBatis, plain JDBC.  
- Best for typical web apps and batch jobs.

**R2DBC PostgreSQL** — reactive, non-blocking  
- Maven: `io.r2dbc:r2dbc-postgresql`  
- Works with Spring WebFlux/Reactor.  
- Best for high-concurrency **reactive** stacks; not a drop-in replacement for JDBC.

> **Rule of thumb**: Using Spring MVC / JPA? → **JDBC**. Building an end‑to‑end **reactive** app (WebFlux)? → **R2DBC**.

## 2) Basic JDBC connection

**pom.xml**
```xml
<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <version>42.7.3</version>
</dependency>
```

**Connect & query**
```java
String url = "jdbc:postgresql://localhost:5432/myapp?applicationName=my-service";
Properties props = new Properties();
props.setProperty("user", "app_user");
props.setProperty("password", "secret");
props.setProperty("sslmode", "require"); // or verify-full with certs

try (Connection con = DriverManager.getConnection(url, props);
     PreparedStatement ps = con.prepareStatement(
         "SELECT id, name FROM customers WHERE email = ?")) {
  ps.setString(1, "ada@example.com");
  try (ResultSet rs = ps.executeQuery()) {
    while (rs.next()) {
      System.out.println(rs.getLong("id") + " " + rs.getString("name"));
    }
  }
}
```

**Useful URL params:** `sslmode`, `currentSchema`, `socketTimeout`, `loginTimeout`, `tcpKeepAlive`, `applicationName`.

## 3) Pooling (HikariCP) and Spring Boot

**HikariCP (standalone)**
```java
HikariConfig cfg = new HikariConfig();
cfg.setJdbcUrl("jdbc:postgresql://localhost:5432/myapp");
cfg.setUsername("app_user");
cfg.setPassword("secret");
cfg.setMaximumPoolSize(20);
cfg.setMinimumIdle(4);
cfg.setConnectionTimeout(10_000);
DataSource ds = new HikariDataSource(cfg);
```

**Spring Boot (Hikari by default)**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/myapp
    username: app_user
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 4
```

**With PgBouncer (transaction pooling):** disable server‑prepared statements:  
`jdbc:postgresql://.../?prepareThreshold=0&autosave=conservative`

## 4) Transactions, isolation, batching

```java
try (Connection con = ds.getConnection()) {
  con.setAutoCommit(false);
  con.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);

  try (PreparedStatement ps = con.prepareStatement(
      "UPDATE accounts SET balance = balance - ? WHERE id = ?")) {
    ps.setBigDecimal(1, new BigDecimal("100.00"));
    ps.setLong(2, 1L);
    ps.addBatch();

    ps.setBigDecimal(1, new BigDecimal("-100.00"));
    ps.setLong(2, 2L);
    ps.addBatch();

    ps.executeBatch();
  }
  con.commit();
}
```

**Fast inserts:** add `reWriteBatchedInserts=true` to URL; driver rewrites batches into multi‑values.  
**Streaming results:** `setAutoCommit(false) + setFetchSize(n)` enables cursor fetch.

## 5) Streaming large results (cursor fetch)

```java
try (Connection con = ds.getConnection()) {
  con.setAutoCommit(false);
  try (PreparedStatement ps = con.prepareStatement(
      "SELECT * FROM big_table ORDER BY id")) {
    ps.setFetchSize(1_000);
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        // process
      }
    }
  }
}
```

> Prevents loading all rows in memory; reduces GC pressure.

## 6) Data type mapping (JSONB, arrays, UUID, …)

**JSONB**
```java
PGobject jsonb = new PGobject();
jsonb.setType("jsonb");
jsonb.setValue("{\"sku\":\"A-1\",\"qty\":2}");
ps.setObject(1, jsonb);

String json = rs.getString("payload");  // parse with Jackson if needed
```

**Arrays**
```java
Array arr = con.createArrayOf("text", new String[]{"a","b","c"});
ps.setArray(1, arr);
String[] out = (String[]) rs.getArray("tags").getArray();
```

**UUID**
```java
ps.setObject(1, UUID.fromString("..."));
UUID id = (UUID) rs.getObject("id");
```

> INET, CITEXT, HSTORE, ranges: store as text or use `PGobject` + extensions.

## 7) COPY API (bulk load) & Large Objects

**COPY (fast ingest/export)**
```java
CopyManager cm = new CopyManager(con.unwrap(BaseConnection.class));
long rows = cm.copyIn(
 "COPY app.customers(id,email) FROM STDIN WITH (FORMAT csv)",
 new StringReader("1,ada@example.com\n2,alan@example.com\n")
);
```

**Large Objects (LO)**
```java
LargeObjectManager lobj = con.unwrap(PGConnection.class).getLargeObjectAPI();
// create/write/read via OIDs — consider bytea for small/medium payloads
```

## 8) Security

- SSL/TLS: `sslmode=require|verify-full` with proper CA/hostname.  
- SCRAM-SHA-256 preferred over md5.  
- Least privilege roles; never SUPERUSER for apps.  
- Secrets outside code (env vars, Vault).  
- Set `applicationName` for observability.

## 9) Performance checklist (pgjdbc)

- Prepared statements everywhere.  
- `reWriteBatchedInserts=true` for heavy inserts.  
- `setFetchSize` for large result sets.  
- Batch changes; avoid chatty per-row I/O.  
- With PgBouncer (transaction pooling): `prepareThreshold=0`, `autosave=conservative`.  
- Pool size tuned to CPU and DB `max_connections`.

## 10) R2DBC quick taste

**pom.xml**
```xml
<dependency>
  <groupId>io.r2dbc</groupId>
  <artifactId>r2dbc-postgresql</artifactId>
  <version>0.9.4.RELEASE</version>
</dependency>
```

**Reactive query**
```java
ConnectionFactory cf = ConnectionFactories.get(
  "r2dbc:postgresql://app_user:secret@localhost:5432/myapp");

Mono.from(cf.create())
  .flatMapMany(conn ->
    conn.createStatement("SELECT id,name FROM customers WHERE email=$1")
        .bind("$1", "ada@example.com")
        .execute()
  )
  .flatMap(res -> res.map((row,meta) -> row.get("id", Long.class)+" "+row.get("name", String.class)))
  .subscribe(System.out::println);
```

## 11) Testing & migrations

- Testcontainers for real PG.  
- Flyway/Liquibase migrations at startup.

```java
@Testcontainers
class RepoTest {
  @Container static PostgreSQLContainer<?> pg = new PostgreSQLContainer<>("postgres:15");
}
```

## 12) Common gotchas

- “permission denied for sequence …” → grant on sequence.  
- Big memory on queries → missing `setFetchSize` + `autoCommit=false`.  
- PgBouncer (transaction pooling) + prepared statements → `prepareThreshold=0`.  
- Time zones → prefer `timestamptz`, align JVM/DB TZ.  
- JSONB → use `PGobject`/framework mapping.
