# GUIDE — Env configuration & manual SQL

## 1) Environment variables
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=normalization_lab
export DB_USER=postgres
export DB_PASSWORD=postgres
```
The app uses them to connect (see application.properties).

## 2) Prepare database and seed. You can just execute the commands from 01_seed_denormalized.sql
```bash
createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" || true
export PGPASSWORD="$DB_PASSWORD"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f sql/01_seed_denormalized.sql
```

## 3) Run the app
```bash
mvn spring-boot:run
```

## 4) Your tasks
- Fix **1NF**: split `orders_flat` → (`orders`, `order_items`); split `customers_bad` → (`customers`, `customer_phones`).
- Fix **2NF**: move product attributes into `products`; keep `(order_id, product_id, qty)` in `order_items_2nf`.
- Fix **3NF**: extract `locations` and `departments`; keep `employees` referencing `dept_id` only.
- Re-check endpoints to confirm anomalies disappear.

## 5) Reference (optional)
If you want to compare against one solution:
```bash
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f sql/02_solution_reference.sql
```
