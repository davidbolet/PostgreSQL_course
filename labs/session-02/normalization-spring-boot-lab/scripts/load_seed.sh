#!/usr/bin/env bash
set -euo pipefail
: "${DB_HOST:=localhost}"
: "${DB_PORT:=5432}"
: "${DB_NAME:=normalization_lab}"
: "${DB_USER:=postgres}"
: "${DB_PASSWORD:=postgres}"
export PGPASSWORD="$DB_PASSWORD"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f sql/01_seed_denormalized.sql
