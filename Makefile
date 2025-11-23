include .env
export $(shell sed 's/=.*//' .env)

ENV_DIR := env
EXEC_APP = docker compose exec --user $(USER_ID):$(GROUP_ID) $(APP)

.env:
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
	@echo ".env generated."

build: .env
	docker compose build

up: .env
	docker compose up -d --remove-orphans

down:
	docker compose down

install-magento:
	$(EXEC_APP) bash -lc "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ."

setup-magento:
	$(EXEC_APP) php -d memory_limit=-1 bin/magento setup:install \
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
		--language=$(LANGUAGE) \
		--currency=$(CURRENCY) \
		--timezone=$(TIMEZONE) \
		--use-rewrites=1 \
		--search-engine=$(SEARCH_ENGINE) \
		--opensearch-host=$(OPENSEARCH_HOST) \
		--opensearch-port=$(OPENSEARCH_PORT) \
		--amqp-host=$(RABBITMQ_HOST) \
		--amqp-port=$(RABBITMQ_PORT) \
		--amqp-user=$(RABBITMQ_DEFAULT_USER) \
		--amqp-password=$(RABBITMQ_DEFAULT_PASS) \
		--amqp-virtualhost=$(RABBITMQ_DEFAULT_VHOST)

cache:
	$(EXEC_APP) bin/magento cache:flush

reindex:
	$(EXEC_APP) bin/magento indexer:reindex

compile:
	$(EXEC_APP) php -d memory_limit=-1 bin/magento setup:di:compile

upgrade:
	$(EXEC_APP) php -d memory_limit=-1 bin/magento setup:upgrade

define run_composer
	$(EXEC_APP) composer $(1)
endef

composer-install:
	$(call run_composer,install)

composer-update:
	$(call run_composer,update)

composer-require:
	$(call run_composer,require $(ARG))

full-install: build up install-magento setup-magento cache reindex
