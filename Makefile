# Load environment file if it exists
ifneq ("$(wildcard .env)","")
	include .env
	export
endif

ENV_DIR := env
APP := app

env:
	@echo "Generating .env from env/ directory…"
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

uninstall-magento:
	docker compose exec -it $(APP) bin/magento setup:uninstall

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

cache:
	docker compose exec -it $(APP) bin/magento cache:flush

reindex:
	docker compose exec -it $(APP) bin/magento indexer:reindex

compile:
	docker compose exec -it $(APP) bin/magento setup:di:compile

upgrade-magento:
	docker compose exec -it $(APP) bin/magento setup:up

permissions:
	docker compose exec -it $(APP) chmod -R 777 var generated pub/static pub/media

define run_composer
	docker compose exec -it --user $(USER_ID):$(GROUP_ID) $(APP) composer $(1)
endef

composer-install:
	$(call run_composer,install)

composer-update:
	$(call run_composer,update)

composer-require:
	$(call run_composer,require $(ARG))

version:
	docker compose exec -it $(APP) php -v

up:
	docker compose up -d --remove-orphans

down:
	docker compose down

restart: down up

build:
	docker compose build

install-magento:
	docker compose exec -it $(APP) bash -lc "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ."

full-install: install-magento setup-magento cache reindex

test-integration:
	docker compose exec -it $(APP) bin/magento dev:tests:run integration --processes $(p) -c"$(c)"

test-integration-all:
	docker compose exec -it $(APP) bin/magento dev:tests:run integration --processes $(p)

test-unit:
	docker compose exec -it $(APP) bin/magento dev:tests:run unit --processes $(p) -c"$(c)"

test-api:
	docker compose exec -it $(APP) bin/magento dev:tests:run api --processes $(p) -c"$(c)"

test-api-all:
	docker compose exec -it $(APP) bin/magento dev:tests:run api --processes $(p)

bash:
	docker compose exec -it $(APP) bash

logs:
	docker logs $(APP) -f