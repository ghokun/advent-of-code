.PHONY: shell
shell:
	psql postgresql://postgres@localhost:9999/postgres

.PHONY: reset
reset:
	docker compose down
	docker compose up -d

.PHONY: format
format:
