# ProgressTree

Corporate knowledge base for **NII Progress** — technical genealogy of R&D documents.

Each document is a **tech gene** linked by parent-child relations (inheritance, inspiration, assembly, fork). Phoenix LiveView + PostgreSQL recursive CTEs + D3 graph visualization.

## Stack

- Elixir 1.17 / Phoenix 1.7 / LiveView
- PostgreSQL 16 (`citext`, recursive CTEs)
- Tailwind CSS, D3.js (LiveView hooks)
- GenServer + Task.Supervisor for graph walks

## Quick start

```bash
# Start PostgreSQL
docker compose up db -d

# Dependencies, DB, server (requires Elixir locally or use Docker)
cd progress_tree
mix deps.get
mix ecto.setup
mix phx.server
```

Open [http://localhost:4000](http://localhost:4000).

### Docker-only workflow

```bash
make setup   # deps + migrate (needs db running)
make server  # phx.server on port 4000
make test
```

DB credentials: `progress_tree` / `progress_tree`, port **5433** on host.

## Project layout

```
progress_tree/
  lib/progress_tree/knowledge/   # TechGene, Tree CTE, Search
  lib/progress_tree/genealogy/   # Walker GenServer (BFS)
  lib/progress_tree_web/live/genealogy_live/
  assets/js/hooks/genealogy_graph.js
```

## License

MIT
