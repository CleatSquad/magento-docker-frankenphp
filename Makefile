include .env
export $(shell sed 's/=.*//' .env)

ENV_DIR := env

.env: /etc/passwd /etc/group Makefile
	@echo "Generating .env from env/ directory…"
	@rm -f .env
	@touch .env
	@for file in $(ENV_DIR)/*.env; do \
		echo "# Loaded from $$file" >> .env; \
		cat $$file >> .env; \
		echo "" >> .env; \
	done
	@echo "USER_ID=$$(id --user ${USER})" >> .env
	@echo "GROUP_ID=$$(id --group ${USER})" >> .env

	@echo ".env generated successfully."

setup-magento:
	docker compose exec $(APP) php -d memory_limit=-1 bin/magento setup:install \
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
	docker compose exec $(APP) bin/magento cache:flush

reindex:
	docker compose exec $(APP) bin/magento indexer:reindex

compile:
	docker compose exec $(APP) php -d memory_limit=-1 bin/magento setup:di:compile

upgrade-magento:
	docker compose exec $(APP) php -d memory_limit=-1 bin/magento setup:up

permissions:
	docker compose exec $(APP) chmod -R 777 var generated pub/static pub/media

define run_composer
	docker compose exec --user $(USER_ID):$(GROUP_ID) $(APP) composer $(1)
endef

composer-install:
	$(call run_composer,install)

composer-update:
	$(call run_composer,update)

composer-require:
	$(call run_composer,require $(ARG))

version:
	docker compose exec $(APP) php -v

up:
	docker compose up -d --remove-orphans

down:
	docker compose down

build:
	docker compose build

install-magento:
	docker compose exec $(APP) bash -lc "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ."

full-install: install-magento setup-magento cache reindex
