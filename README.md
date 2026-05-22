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
docker run -d --name progress_tree_db \
  -e POSTGRES_USER=progress_tree \
  -e POSTGRES_PASSWORD=progress_tree \
  -e POSTGRES_DB=progress_tree_dev \
  -p 5433:5432 postgres:16-alpine

cd progress_tree
mix deps.get
mix assets.setup && mix assets.build
mix ecto.setup
mix phx.server
```

Open [http://localhost:4000](http://localhost:4000).

### Docker Makefile

```bash
make setup   # deps + migrate
make test
make server
```

DB: `progress_tree` / `progress_tree`, host port **5433**.

## Portfolio — Weallfamily

This project mirrors **genealogical tree** problems at scale:

| Weallfamily domain | ProgressTree analogue |
|--------------------|------------------------|
| Persons & pedigrees | Tech genes & R&D lineage |
| Parent-child links | `tech_relations` (наследование, форк, …) |
| Common ancestor search | `Genealogy.Walker` bidirectional BFS |
| Large graph UI | LiveView + D3 force layout |
| Historical depth | Documents from 1987–2022 (demo seeds) |

**Demo flow for interviews:**

1. Open catalog, search `ПЧ-400`
2. Open gene page — explore force graph
3. Click **Показать цепочку наследования** — highlight path to 1987 prototype
4. **Сравнить с потомком** — async common ancestor via GenServer

## Project layout

```
progress_tree/
  lib/progress_tree/knowledge/     # TechGene, Tree CTE, Search, Graph
  lib/progress_tree/genealogy/     # Walker GenServer
  lib/progress_tree_web/live/genealogy_live/
  assets/js/hooks/genealogy_graph.js
livebooks/graph_algorithms.livemd
```

## Deploy (Fly.io)

```bash
cd progress_tree
fly launch --no-deploy
fly secrets set DATABASE_URL=ecto://...
fly deploy
```

## Tests

```bash
cd progress_tree
mix test
mix test --only integration   # requires seeds
```

## License

MIT
