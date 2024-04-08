#!/bin/bash
set -e

# Define all required environment variables (excluding optional ones like RABBITMQ_DEFAULT_USER)
required_env_vars=(
    "MAGENTO_PUBLIC_KEY"
    "MAGENTO_PRIVATE_KEY"
    "MAGENTO_PROJECT_EDITION"
    "MAGENTO_VERSION"
    "MYSQL_HOST"
    "MYSQL_DATABASE"
    "MYSQL_USER"
    "MYSQL_PASSWORD"
    "SERVER_NAME"
    "MAGENTO_ADMIN_FRONTNAME"
    "MAGENTO_ADMIN_FIRST_NAME"
    "MAGENTO_ADMIN_LAST_NAME"
    "MAGENTO_ADMIN_EMAIL"
    "MAGENTO_ADMIN_USER"
    "MAGENTO_ADMIN_PASSWORD"
    "MAGENTO_LOCALE"
    "MAGENTO_CURRENCY"
    "MAGENTO_TIMEZONE"
    "REDIS_CACHE_BACKEND_SERVER"
    "REDIS_CACHE_BACKEND_DB"
    "REDIS_PAGE_CACHE_SERVER"
    "REDIS_PAGE_CACHE_DB"
    "REDIS_SESSION_SAVE_HOST"
    "ES_HOST"
    "ES_PORT"
    "OPENSEARCH_HOST"
    "OPENSEARCH_PORT"
)

# Check for missing required environment variables
for var in "${required_env_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: Environment variable $var is not defined."
        exit 1
    fi
done

if [ "$1" = 'frankenphp' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/magento' ]; then
    # Check if Magento project is already set up
    if [ ! -f composer.json ]; then
        echo "Setting up Magento project for the first time..."
        rm -Rf tmp/
        composer config -g http-basic.repo.magento.com "$MAGENTO_PUBLIC_KEY" "$MAGENTO_PRIVATE_KEY"
        composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition="$MAGENTO_VERSION" tmp --stability=stable --prefer-dist --no-progress --no-interaction --no-install
        cd tmp
        cp -Rp . ..
        cd -
        rm -Rf tmp/
    fi

    # Install Magento dependencies
    composer install --prefer-dist --no-progress --no-interaction

    # Check if Magento is already installed
    if [ ! -f app/etc/env.php ]; then
        echo "Installing Magento..."
        install_cmd="bin/magento setup:install \
          --db-host=\"$MYSQL_HOST\" \
          --db-name=\"$MYSQL_DATABASE\" \
          --db-user=\"$MYSQL_USER\" \
          --db-password=\"$MYSQL_PASSWORD\" \
          --base-url=\"http://$SERVER_NAME/\" \
          --base-url-secure=\"https://$SERVER_NAME/\" \
          --backend-frontname=\"$MAGENTO_ADMIN_FRONTNAME\" \
          --admin-firstname=\"$MAGENTO_ADMIN_FIRST_NAME\" \
          --admin-lastname=\"$MAGENTO_ADMIN_LAST_NAME\" \
          --admin-email=\"$MAGENTO_ADMIN_EMAIL\" \
          --admin-user=\"$MAGENTO_ADMIN_USER\" \
          --admin-password=\"$MAGENTO_ADMIN_PASSWORD\" \
          --language=\"$MAGENTO_LOCALE\" \
          --currency=\"$MAGENTO_CURRENCY\" \
          --timezone=\"$MAGENTO_TIMEZONE\" \
          --use-rewrites=1"

        # Conditional RabbitMQ configuration
        if [ ! -z "$RABBITMQ_DEFAULT_USER" ]; then
            install_cmd+=" --amqp-host=\"$RABBITMQ_HOST\" \
              --amqp-port=\"$RABBITMQ_PORT\" \
              --amqp-user=\"$RABBITMQ_DEFAULT_USER\" \
              --amqp-password=\"$RABBITMQ_DEFAULT_PASS\" \
              --amqp-virtualhost=\"$RABBITMQ_DEFAULT_VHOST\""
        fi

        # Redis and Elasticsearch/OpenSearch configurations are always added
        install_cmd+=" --cache-backend=redis \
          --cache-backend-redis-server=\"$REDIS_CACHE_BACKEND_SERVER\" \
          --cache-backend-redis-db=\"$REDIS_CACHE_BACKEND_DB\" \
          --page-cache=redis \
          --page-cache-redis-server=\"$REDIS_PAGE_CACHE_SERVER\" \
          --page-cache-redis-db=\"$REDIS_PAGE_CACHE_DB\" \
          --session-save=redis \
          --session-save-redis-host=\"$REDIS_SESSION_SAVE_HOST\" \
          --session-save-redis-db=2 \
          --elasticsearch-host=\"$ES_HOST\" \
          --elasticsearch-port=\"$ES_PORT\" \
          --opensearch-host=\"$OPENSEARCH_HOST\" \
          --opensearch-port=\"$OPENSEARCH_PORT\" \
          --search-engine=\"opensearch\""

        # Execute the installation command
        eval $install_cmd
	else
        echo "Magento is already installed."
    fi
	# Set proper permissions after installation
	setfacl -R -m u:www-data:rwX -m u:"$(whoami)":rwX var pub/static pub/media app/etc generated
	setfacl -dR -m u:www-data:rwX -m u:"$(whoami)":rwX var pub/static pub/media app/etc generated
	if [ ! -f /etc/caddy/certs/tls.pem ]; then
		mkdir -p /etc/caddy/certs
		mkcert -install
		mkcert -cert-file /etc/caddy/certs/tls.pem -key-file  /etc/caddy/certs/tls.key "$SERVER_NAME"
	fi
fi

exec docker-php-entrypoint "$@"
