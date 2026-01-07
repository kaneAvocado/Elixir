.PHONY: setup deps test server migrate

setup: deps migrate

deps:
	docker compose run --rm --no-deps -w /app/progress_tree elixir:1.17 mix deps.get || \
	docker run --rm -v "$(PWD)":/app -w /app/progress_tree elixir:1.17 bash -c "apt-get update -qq && apt-get install -y -qq git build-essential > /dev/null && mix local.hex --force && mix deps.get"

migrate:
	docker run --rm --network host -v "$(PWD)":/app -w /app/progress_tree elixir:1.17 bash -c "\
		apt-get update -qq && apt-get install -y -qq git build-essential > /dev/null && \
		mix local.hex --force && mix deps.get && \
		MIX_ENV=dev mix ecto.create && mix ecto.migrate"

test:
	docker run --rm --network host -v "$(PWD)":/app -w /app/progress_tree elixir:1.17 bash -c "\
		apt-get update -qq && apt-get install -y -qq git build-essential > /dev/null && \
		mix local.hex --force && mix deps.get && MIX_ENV=test mix test"

server:
	docker compose up db -d
	docker run --rm -it --network host -v "$(PWD)":/app -w /app/progress_tree -e MIX_ENV=dev elixir:1.17 bash -c "\
		apt-get update -qq && apt-get install -y -qq git build-essential nodejs npm > /dev/null && \
		mix local.hex --force && mix deps.get && mix assets.setup && mix assets.build && \
		mix phx.server"
