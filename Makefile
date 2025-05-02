# Variables
COMPOSE := docker compose
COMPOSE_BASE := -f docker-compose.yml
COMPOSE_DEV := $(COMPOSE_BASE) -f docker-compose.dev.yml
COMPOSE_PROD := $(COMPOSE_BASE) -f docker-compose.prod.yml
CSV_FILE ?= samples/main.csv
SECRETS_DIR := docker/secrets

.PHONY: help dev prod validate-csv test down clean prune secrets

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

dev:  ## Start development environment with config.ini
	$(COMPOSE) $(COMPOSE_DEV) up --build

prod:  ## Start production environment (uses secrets)
	$(COMPOSE) $(COMPOSE_PROD) up --build -d

validate-csv:  ## Validate a CSV file (set CSV_FILE=path/to/file)
	./scripts/validate_nfirs_csv.sh $(CSV_FILE)

test:  ## Run unit tests
	pytest tests/

down:  ## Stop and remove containers
	$(COMPOSE) $(COMPOSE_BASE) down

clean: down  ## Remove containers, networks, and volumes
	$(COMPOSE) $(COMPOSE_BASE) down -v
	docker image prune -f

prune: clean  ## Full cleanup (containers, volumes, images, build cache)
	docker system prune -a --volumes -f

secrets:  ## Create Docker secrets from config.ini
	@mkdir -p $(SECRETS_DIR)
	@./scripts/create_docker_secrets.sh
	@echo "Secrets created in $(SECRETS_DIR)"