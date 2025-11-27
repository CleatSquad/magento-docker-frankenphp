# Magento Docker FrankenPHP - Makefile
# Common commands for managing the Docker environment

# Load environment file if it exists
ifneq ("$(wildcard .env)","")
	include .env
	export
endif

# Configuration
ENV_DIR := env
APP := app

# Default shell
SHELL := /bin/bash

.PHONY: env uninstall-magento setup-magento cache reindex compile upgrade-magento \
        permissions composer-install composer-update composer-require version \
        up down restart build install-magento full-install \
        test-integration test-integration-all test-unit test-api test-api-all \
        bash logs help

# Generate .env file from env/ directory templates
env:
	@echo "Generating .env from env/ directory..."
	@rm -f .env
	@touch .env
	@for file in $(ENV_DIR)/*.env; do \
		echo "# Loaded from $$file" >> .env; \
		cat $$file >> .env; \
		echo "" >> .env; \
	done
	@echo "USER_ID=$$(id -u)" >> .env
	@echo "GROUP_ID=$$(id -g)" >> .env
	@echo ".env generated successfully."

# Uninstall Magento (removes all data)
uninstall-magento:
	docker compose exec -it $(APP) bin/magento setup:uninstall

# Install Magento with configured settings
setup-magento:
	docker compose exec -it $(APP) bin/magento setup:install \
		--base-url=$(BASE_URL) \
		--db-host=$(DB_HOST) \
		--db-name=$(DB_NAME) \
		--db-user=$(DB_USER) \
		--db-password=$(DB_PASSWORD) \
		--backend-frontname=$(BACKEND_FRONTNAME) \
		--admin-firstname=$(ADMIN_FIRSTNAME) \
		--admin-lastname=$(ADMIN_LASTNAME) \
		--admin-email=$(ADMIN_EMAIL) \
		--admin-user=$(ADMIN_USER) \
		--admin-password=$(ADMIN_PASSWORD) \
		--language=fr_FR \
		--currency=EUR \
		--timezone=Europe/Paris \
		--use-rewrites=1 \
		--search-engine=$(SEARCH_ENGINE) \
		--opensearch-host=$(OPENSEARCH_HOST) \
		--opensearch-port=$(OPENSEARCH_PORT) \
		--amqp-host=$(RABBITMQ_HOST) \
		--amqp-port=$(RABBITMQ_PORT) \
		--amqp-user=$(RABBITMQ_DEFAULT_USER) \
		--amqp-password=$(RABBITMQ_DEFAULT_PASS) \
		--amqp-virtualhost=$(RABBITMQ_DEFAULT_VHOST) \
		--amqp-ssl=0 \
		--session-save=redis \
		--session-save-redis-host=$(VALKEY_HOST) \
		--session-save-redis-port=$(VALKEY_PORT) \
		--session-save-redis-db=2 \
		--session-save-redis-disable-locking=1 \
		--cache-backend=redis \
		--cache-backend-redis-server=$(VALKEY_HOST) \
		--cache-backend-redis-port=$(VALKEY_PORT) \
		--cache-backend-redis-db=0 \
		--page-cache=redis \
		--page-cache-redis-server=$(VALKEY_HOST) \
		--page-cache-redis-port=$(VALKEY_PORT) \
		--page-cache-redis-db=1

# Clear all Magento caches
cache:
	docker compose exec -it $(APP) bin/magento cache:flush

# Reindex all Magento indexers
reindex:
	docker compose exec -it $(APP) bin/magento indexer:reindex

# Compile dependency injection
compile:
	docker compose exec -it $(APP) bin/magento setup:di:compile

# Run Magento setup upgrade
upgrade-magento:
	docker compose exec -it $(APP) bin/magento setup:up

# Fix file permissions (development only)
permissions:
	docker compose exec -it $(APP) chmod -R 777 var generated pub/static pub/media

# Helper function for running Composer commands
define run_composer
	docker compose exec -it --user $(USER_ID):$(GROUP_ID) $(APP) composer $(1)
endef

# Install Composer dependencies
composer-install:
	$(call run_composer,install)

# Update Composer dependencies
composer-update:
	$(call run_composer,update)

# Require a new Composer package (usage: make composer-require ARG=vendor/package)
composer-require:
	$(call run_composer,require $(ARG))

# Display PHP version
version:
	docker compose exec -it $(APP) php -v

# Start Docker containers
up:
	docker compose up -d --remove-orphans

# Stop Docker containers
down:
	docker compose down

# Restart Docker containers
restart: down up

# Build Docker images
build:
	docker compose build

# Create a new Magento project
install-magento:
	docker compose exec -it $(APP) bash -lc "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ."

# Full Magento installation (create project, setup, cache, reindex)
full-install: install-magento setup-magento cache reindex

# Run Magento integration tests (usage: make test-integration p=4 c="Magento/Catalog")
test-integration:
	docker compose exec -it $(APP) bin/magento dev:tests:run integration --processes $(p) -c"$(c)"

# Run all Magento integration tests (usage: make test-integration-all p=4)
test-integration-all:
	docker compose exec -it $(APP) bin/magento dev:tests:run integration --processes $(p)

# Run Magento unit tests (usage: make test-unit p=4 c="Magento/Catalog")
test-unit:
	docker compose exec -it $(APP) bin/magento dev:tests:run unit --processes $(p) -c"$(c)"

# Run Magento API tests (usage: make test-api p=4 c="Magento/Catalog")
test-api:
	docker compose exec -it $(APP) bin/magento dev:tests:run api --processes $(p) -c"$(c)"

# Run all Magento API tests (usage: make test-api-all p=4)
test-api-all:
	docker compose exec -it $(APP) bin/magento dev:tests:run api --processes $(p)

# Open a shell in the app container
bash:
	docker compose exec -it $(APP) bash

# Follow container logs
logs:
	docker logs $(APP) -f

# Display help
help:
	@echo "Available targets:"
	@echo "  env                 - Generate .env from env/ directory"
	@echo "  up                  - Start Docker containers"
	@echo "  down                - Stop Docker containers"
	@echo "  restart             - Restart Docker containers"
	@echo "  build               - Build Docker images"
	@echo "  bash                - Open shell in app container"
	@echo "  logs                - Follow container logs"
	@echo "  install-magento     - Create new Magento project"
	@echo "  setup-magento       - Install Magento with settings"
	@echo "  full-install        - Full Magento installation"
	@echo "  cache               - Clear Magento caches"
	@echo "  reindex             - Reindex Magento"
	@echo "  compile             - Compile DI"
	@echo "  upgrade-magento     - Run setup:upgrade"
	@echo "  permissions         - Fix file permissions"
	@echo "  composer-install    - Install Composer dependencies"
	@echo "  composer-update     - Update Composer dependencies"
	@echo "  composer-require    - Require package (ARG=vendor/package)"
	@echo "  version             - Display PHP version"
	@echo "  test-unit           - Run unit tests"
	@echo "  test-integration    - Run integration tests"
	@echo "  test-api            - Run API tests"