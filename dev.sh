#!/usr/bin/env bash
# Run ProgressTree without local Elixir — only Docker required.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/progress_tree"
DB_NAME="${DB_CONTAINER:-progress_tree_db}"

ensure_db() {
  if docker ps -a --format '{{.Names}}' | grep -qx "$DB_NAME"; then
    docker start "$DB_NAME" >/dev/null 2>&1 || true
  else
    echo "Starting PostgreSQL on port 5433..."
    docker run -d --name "$DB_NAME" \
      -e POSTGRES_USER=progress_tree \
      -e POSTGRES_PASSWORD=progress_tree \
      -e POSTGRES_DB=progress_tree_dev \
      -p 5433:5432 \
      postgres:16-alpine
  fi
  echo "Waiting for PostgreSQL..."
  for i in $(seq 1 30); do
    if docker exec "$DB_NAME" pg_isready -U progress_tree >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  echo "PostgreSQL did not become ready in time." >&2
  exit 1
}

run_mix() {
  docker run --rm --network host \
    -v "$ROOT:/app" -w /app/progress_tree \
    -e MIX_ENV="${MIX_ENV:-dev}" \
    -e PGHOST=localhost -e PGPORT=5433 \
    -e PGUSER=progress_tree -e PGPASSWORD=progress_tree \
    elixir:1.17 bash -c '
      apt-get update -qq
      apt-get install -y -qq git build-essential nodejs npm > /dev/null
      mix local.hex --force
      mix local.rebar --force
      '"$1"'
    '
}

cmd="${1:-server}"

case "$cmd" in
  setup)
    ensure_db
    run_mix "mix deps.get && mix assets.setup && mix assets.build && mix ecto.create && mix ecto.migrate && mix run -e 'ProgressTree.Seeds.run()'"
    echo "Setup complete."
    ;;
  server)
    ensure_db
    echo "Open http://localhost:4000"
    run_mix "mix deps.get && mix assets.setup && mix assets.build && mix ecto.create 2>/dev/null; mix ecto.migrate && mix run -e 'ProgressTree.Seeds.run()' && mix phx.server"
    ;;
  test)
    ensure_db
    run_mix "MIX_ENV=test mix deps.get && mix ecto.create --quiet 2>/dev/null; mix ecto.migrate --quiet && mix test"
    ;;
  migrate)
    ensure_db
    run_mix "mix deps.get && mix ecto.migrate"
    ;;
  seeds)
    ensure_db
    run_mix "mix deps.get && mix run -e 'ProgressTree.Seeds.run()'"
    ;;
  *)
    echo "Usage: ./dev.sh [setup|server|test|migrate|seeds]"
    exit 1
    ;;
esac
