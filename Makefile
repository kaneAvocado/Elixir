.PHONY: setup deps test server migrate seeds

# Docker-only workflow (no local Elixir required)
ROOT := $(shell pwd)

setup:
	./dev.sh setup

server:
	./dev.sh server

test:
	./dev.sh test

migrate:
	./dev.sh migrate

seeds:
	./dev.sh seeds

deps:
	./dev.sh setup
