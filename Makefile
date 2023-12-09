.PHONY: psql
psql:
	psql postgresql://postgres@localhost:9999/postgres

.PHONY: reset
reset:
	docker compose down
	docker compose up -d
