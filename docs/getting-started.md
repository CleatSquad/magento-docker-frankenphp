# Getting Started

This guide walks you through setting up a Magento 2 development environment using the FrankenPHP Docker images.

## Prerequisites

- **Docker** >= 24.0
- **Docker Compose** >= 2.20
- **Git**
- At least 8GB RAM allocated to Docker
- Magento Marketplace credentials (for Composer)

## Quick Setup

### 1. Clone the Repository

```bash
# Option 1: Use as template (recommended)
# Click "Use this template" on GitHub, then clone your repo

# Option 2: Clone directly
git clone https://github.com/mohaelmrabet/magento-frankenphp-template.git
cd magento-frankenphp-template
```

### 2. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your settings (optional)
nano .env
```

### 3. Run the Setup Script

```bash
./bin/setup
```

This script will:
- ✅ Create the `proxy` Docker network
- ✅ Copy environment files from templates
- ✅ Set your user ID/GID for proper file permissions
- ✅ Auto-generate SSL certificates (if `SERVER_NAME` is set)

### 3. Start Containers

```bash
# Development
docker compose up -d

# Production
docker compose -f docker-compose.prod.yml up -d
```

### 4. Access Your Services

| Service | URL |
|---------|-----|
| Magento | https://magento.localhost |
| Mailhog | http://mailhog.localhost |
| RabbitMQ | http://rabbit.localhost |
| phpMyAdmin | http://myadmin.localhost |

## Installing Magento

### Configure Credentials

Edit `.env` to add your Magento Marketplace credentials:

```bash
COMPOSER_AUTH={"http-basic":{"repo.magento.com":{"username":"YOUR_PUBLIC_KEY","password":"YOUR_PRIVATE_KEY"}}}
```

Or create `src/auth.json`:

```json
{
    "http-basic": {
        "repo.magento.com": {
            "username": "YOUR_PUBLIC_KEY",
            "password": "YOUR_PRIVATE_KEY"
        }
    }
}
```

### Install Magento via Composer

```bash
# Enter the container
docker compose exec app bash

# Create Magento project
composer create-project --repository-url=https://repo.magento.com/ \
    magento/project-community-edition .

# Run the installer
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
    --amqp-password=magento

# Set developer mode
bin/magento deploy:mode:set developer

# Disable Two-Factor Auth for development
bin/magento module:disable Magento_AdminAdobeImsTwoFactorAuth Magento_TwoFactorAuth

# Clear cache
bin/magento cache:flush
```

## Included Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| **app** | mohelmrabet/magento-frankenphp | 80, 443 | FrankenPHP + Caddy |
| **mariadb** | mariadb:11.4 | 3306 | Database |
| **opensearch** | opensearch:2.x | 9200 | Search engine |
| **valkey** | valkey:8.1 | 6379 | Cache & Sessions |
| **rabbitmq** | rabbitmq:4.1 | 5672, 15672 | Message queue |
| **mailhog** | mailhog | 8025 | Email catcher (dev) |

## Project Structure

```
magento-docker-frankenphp/
├── bin/                    # CLI tools
├── conf/                   # Configuration files
├── docs/                   # Documentation
├── env/                    # Environment templates
├── examples/               # Deployment examples
├── images/                 # Docker images
│   ├── opensearch/         # OpenSearch configuration
│   └── rabbitmq/           # RabbitMQ configuration
├── src/                    # Magento source (gitignored)
├── docker-compose.yml      # Development
├── docker-compose.prod.yml # Production
└── Makefile
```

## Next Steps

- [Configure environment variables](configuration.md)
- [Learn the CLI tools](CLI.md)
- [Setup Xdebug](xdebug.md)
- [Deploy to production](../examples/production-dockerfile.md)
