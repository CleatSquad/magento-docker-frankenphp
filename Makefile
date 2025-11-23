APP=app

BASE_URL=https://magento.localhost/
ADMIN_FIRSTNAME=Admin
ADMIN_LASTNAME=User
ADMIN_EMAIL=admin@example.com
ADMIN_USER=admin
ADMIN_PASSWORD=Admin123!
BACKEND_FRONTNAME=admin
DB_HOST=mariadb
DB_NAME=magento
DB_USER=magento
DB_PASSWORD=magento
SEARCH_ENGINE=opensearch
OPENSEARCH_HOST=opensearch
OPENSEARCH_PORT=9200

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
		--opensearch-port=$(OPENSEARCH_PORT)

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

composer:
	docker compose exec $(APP) php -d memory_limit=-1 bin/composer

up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

install-magento:
	docker compose exec $(APP) bash -lc "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition ."


