# Magento Docker FrankenPHP - Makefile
# Common commands for managing the Docker environment
#
# NOTE: CLI tools are also available in the bin/ directory.
# See docs/CLI.md for full documentation.

# Load environment file if it exists
ifneq ("$(wildcard .env)","")
	include env/*.env
	include .env
	export
endif

# Configuration
APP := app

# Default shell
SHELL := /bin/bash

.PHONY: help uninstall-magento setup-magento cache reindex compile upgrade-magento \
        permissions composer-install composer-update composer-require version \
        up down restart build install-magento full-install \
        test-integration test-integration-all test-unit test-api test-api-all \
        bash logs status remove removeall fixowns fixperms mysql mysqldump redis deploy

# Default target - display help
.DEFAULT_GOAL := help

# Uninstall Magento (removes all data)
uninstall-magento:
	./bin/uninstall-magento

# Install Magento with interactive setup
setup-magento:
	./bin/setup-magento

# Clear all Magento caches
cache:
	./bin/cache-flush

# Reindex all Magento indexers
reindex:
	./bin/reindex

# Compile dependency injection
compile:
	./bin/di-compile

# Run Magento setup upgrade
upgrade-magento:
	./bin/setup-upgrade

# Fix file permissions (development only)
permissions:
	./bin/fixowns
	./bin/fixperms

# Install Composer dependencies
composer-install:
	./bin/composer install

# Update Composer dependencies
composer-update:
	./bin/composer update

# Require a new Composer package (usage: make composer-require ARG=vendor/package)
composer-require:
	./bin/composer require $(ARG)

# Display PHP version
version:
	./bin/cli php -v

# Start Docker containers
up:
	./bin/start

# Stop Docker containers
down:
	./bin/stop

# Restart Docker containers
restart:
	./bin/restart

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
	./bin/magento dev:tests:run integration --processes $(p) -c"$(c)"

# Run all Magento integration tests (usage: make test-integration-all p=4)
test-integration-all:
	./bin/magento dev:tests:run integration --processes $(p)

# Run Magento unit tests (usage: make test-unit p=4 c="Magento/Catalog")
test-unit:
	./bin/magento dev:tests:run unit --processes $(p) -c"$(c)"

# Run Magento API tests (usage: make test-api p=4 c="Magento/Catalog")
test-api:
	./bin/magento dev:tests:run api --processes $(p) -c"$(c)"

# Run all Magento API tests (usage: make test-api-all p=4)
test-api-all:
	./bin/magento dev:tests:run api --processes $(p)

# Open a shell in the app container
bash:
	./bin/bash

# Follow container logs
logs:
	./bin/logs

# Show container status
status:
	./bin/status

# Remove containers
remove:
	./bin/remove

# Remove containers, volumes and networks
removeall:
	./bin/removeall

# Fix file ownership
fixowns:
	./bin/fixowns

# Fix file permissions
fixperms:
	./bin/fixperms

# Access MySQL CLI
mysql:
	./bin/mysql

# Dump database
mysqldump:
	./bin/mysqldump

# Access Redis CLI
redis:
	./bin/redis

# Deploy static content
deploy:
	./bin/deploy -f

# Display help
help:
	@echo "Available targets:"
	@echo ""
	@echo "Container Management:"
	@echo "  up                  - Start Docker containers"
	@echo "  down                - Stop Docker containers"
	@echo "  restart             - Restart Docker containers"
	@echo "  status              - Show container status"
	@echo "  build               - Build Docker images"
	@echo "  remove              - Remove containers"
	@echo "  removeall           - Remove containers, volumes and networks"
	@echo "  bash                - Open shell in app container"
	@echo "  logs                - Follow container logs"
	@echo ""
	@echo "Magento Commands:"
	@echo "  install-magento     - Create new Magento project"
	@echo "  setup-magento       - Interactive Magento installation"
	@echo "  uninstall-magento   - Uninstall Magento"
	@echo "  full-install        - Full Magento installation"
	@echo "  cache               - Clear Magento caches"
	@echo "  reindex             - Reindex Magento"
	@echo "  compile             - Compile DI"
	@echo "  upgrade-magento     - Run setup:upgrade"
	@echo "  deploy              - Deploy static content"
	@echo ""
	@echo "Composer Commands:"
	@echo "  composer-install    - Install Composer dependencies"
	@echo "  composer-update     - Update Composer dependencies"
	@echo "  composer-require    - Require package (ARG=vendor/package)"
	@echo ""
	@echo "Database & Cache:"
	@echo "  mysql               - Access MySQL CLI"
	@echo "  mysqldump           - Dump database"
	@echo "  redis               - Access Redis CLI"
	@echo ""
	@echo "File Operations:"
	@echo "  permissions         - Fix file permissions"
	@echo "  fixowns             - Fix file ownership"
	@echo "  fixperms            - Fix file permissions"
	@echo ""
	@echo "Testing:"
	@echo "  test-unit           - Run unit tests"
	@echo "  test-integration    - Run integration tests"
	@echo "  test-api            - Run API tests"
	@echo ""
	@echo "Other:"
	@echo "  version             - Display PHP version"
	@echo ""
	@echo "For detailed CLI documentation, see: docs/CLI.md"
