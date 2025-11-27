# Example: Local Development Setup

This example provides a step-by-step guide for setting up a local Magento development environment using the FrankenPHP Docker images.

## Prerequisites

- Docker >= 24.0
- Docker Compose >= 2.20
- Git
- At least 8GB of RAM allocated to Docker
- Magento Marketplace credentials (for Composer)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/CleatSquad/magento-docker-frankenphp.git
cd magento-docker-frankenphp
```

### 2. Run Setup Script

```bash
./bin/setup.sh
```

This script will:
- Create the `proxy` Docker network
- Copy environment file templates
- Configure user permissions

### 3. Configure Magento Credentials

Edit `.env` to add your Magento Marketplace credentials:

```bash
# .env
COMPOSER_AUTH={"http-basic":{"repo.magento.com":{"username":"YOUR_PUBLIC_KEY","password":"YOUR_PRIVATE_KEY"}}}
```

Or configure Composer auth directly:

```bash
# Create auth.json in src directory
mkdir -p src
cat > src/auth.json << 'EOF'
{
    "http-basic": {
        "repo.magento.com": {
            "username": "YOUR_PUBLIC_KEY",
            "password": "YOUR_PRIVATE_KEY"
        }
    }
}
EOF
```

### 4. Start the Services

```bash
docker compose up -d
```

Wait for all services to be healthy:

```bash
docker compose ps
```

### 5. Install Magento

```bash
# Enter the container
docker compose exec app bash

# Create Magento project
composer create-project --repository-url=https://repo.magento.com/ \
    magento/project-community-edition .

# Install Magento
bin/magento setup:install \
    --base-url=https://magento.localhost/ \
    --db-host=mariadb \
    --db-name=magento \
    --db-user=magento \
    --db-password=magento \
    --admin-firstname=Admin \
    --admin-lastname=User \
    --admin-email=admin@example.com \
    --admin-user=admin \
    --admin-password=Admin123! \
    --language=en_US \
    --currency=USD \
    --timezone=America/New_York \
    --use-rewrites=1 \
    --search-engine=opensearch \
    --opensearch-host=opensearch \
    --opensearch-port=9200 \
    --session-save=redis \
    --session-save-redis-host=valkey \
    --session-save-redis-port=6379 \
    --session-save-redis-db=2 \
    --cache-backend=redis \
    --cache-backend-redis-server=valkey \
    --cache-backend-redis-port=6379 \
    --cache-backend-redis-db=0 \
    --page-cache=redis \
    --page-cache-redis-server=valkey \
    --page-cache-redis-port=6379 \
    --page-cache-redis-db=1 \
    --amqp-host=rabbitmq \
    --amqp-port=5672 \
    --amqp-user=magento \
    --amqp-password=magento \
    --amqp-virtualhost=/

# Set developer mode
bin/magento deploy:mode:set developer

# Disable Two-Factor Auth for development
bin/magento module:disable Magento_AdminAdobeImsTwoFactorAuth Magento_TwoFactorAuth

# Clear cache
bin/magento cache:flush
```

### 6. Access Magento

| Service | URL |
|---------|-----|
| Magento Frontend | https://magento.localhost |
| Magento Admin | https://magento.localhost/admin |
| Mailhog | http://mailhog.localhost |
| RabbitMQ | http://rabbit.localhost |
| phpMyAdmin | http://myadmin.localhost |
| Traefik Dashboard | http://traefik.localhost |

## Using Makefile Commands

The project includes a Makefile with common commands:

```bash
# Start services
make up

# Stop services
make down

# Restart services
make restart

# Clear Magento cache
make cache

# Reindex Magento
make reindex

# Run Composer install
make composer-install

# Run Composer update
make composer-update

# Access container shell
make bash

# View logs
make logs
```

## Xdebug Configuration

The development image includes Xdebug preconfigured. To use it:

### PHPStorm Setup

1. Go to **Settings > PHP > Debug**
2. Set **Xdebug port** to `9003`
3. Go to **Settings > PHP > Servers**
4. Add a new server:
   - **Name**: `magento.localhost`
   - **Host**: `magento.localhost`
   - **Port**: `443`
   - **Debugger**: `Xdebug`
   - **Use path mappings**: Yes
   - Map `/var/www/html` to your local `src` directory

### VS Code Setup

Add this configuration to `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}/src"
            }
        }
    ]
}
```

### Triggering Xdebug

Add `?XDEBUG_SESSION=PHPSTORM` to the URL or use a browser extension like [Xdebug Helper](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc).

## Email Testing with Mailhog

All emails sent from Magento are captured by Mailhog. Access the Mailhog interface at http://mailhog.localhost to view sent emails.

## Troubleshooting

### Permission Issues

```bash
# Fix permissions from inside the container
docker compose exec app bash
chown -R www-data:www-data var generated pub/static pub/media
chmod -R 775 var generated pub/static pub/media
```

Or use the Makefile:

```bash
make permissions
```

### Container Won't Start

Check the logs:

```bash
docker compose logs app
docker compose logs opensearch
docker compose logs mariadb
```

### OpenSearch Memory Issues

Increase Docker memory allocation or reduce OpenSearch heap:

```bash
# In env/opensearch.env
OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m
```

### Slow Performance on macOS/Windows

Use Docker's built-in file sync or a tool like Mutagen for better file sync performance:

```yaml
# docker-compose.override.yml
services:
  app:
    volumes:
      - type: bind
        source: ./src
        target: /var/www/html
        consistency: cached
```
