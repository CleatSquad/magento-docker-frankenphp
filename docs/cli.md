# CLI Tools Documentation

This document provides comprehensive documentation for all CLI tools available in the `bin/` directory.

## Table of Contents

- [Getting Started](#getting-started)
- [Container Management](#container-management)
- [Shell Access](#shell-access)
- [Magento Commands](#magento-commands)
- [Composer Commands](#composer-commands)
- [Database Commands](#database-commands)
- [Cache & Redis](#cache--redis)
- [File Operations](#file-operations)
- [Node.js Commands](#nodejs-commands)

---

## Getting Started

All CLI tools are located in the `bin/` directory. Make sure to run them from the project root:

```bash
# Example: Start containers
./bin/start

# Example: Run Magento command
./bin/magento cache:flush
```

---

## Container Management

### `bin/start`

Start all Docker containers.

```bash
./bin/start
```

**Auto-setup:** If `.env` file is missing, `bin/start` will automatically run `bin/setup` first to initialize the environment.

### `bin/stop`

Stop all Docker containers.

```bash
./bin/stop
```

### `bin/restart`

Restart all Docker containers.

```bash
./bin/restart
```

### `bin/status`

Show the status of all containers.

```bash
./bin/status
```

### `bin/logs`

Follow container logs.

```bash
# Follow all container logs
./bin/logs

# Follow logs for a specific container
./bin/logs app
./bin/logs mariadb
```

### `bin/remove`

Remove all Docker containers.

```bash
./bin/remove
```

### `bin/removeall`

Remove all Docker containers, volumes, and networks.

```bash
./bin/removeall
```

---

## Shell Access

### `bin/bash`

Open a bash shell in the app container.

```bash
./bin/bash
```

### `bin/cli`

Run any command in the app container.

```bash
./bin/cli ls -la
./bin/cli php -v
./bin/cli whoami
```

### `bin/clinotty`

Run commands without TTY (useful for scripting and piping).

```bash
./bin/clinotty php -m | grep -i mysql
```

### `bin/root`

Run commands as root in the app container.

```bash
./bin/root apt-get update
./bin/root chown -R www-data:www-data /var/www/html
```

### `bin/rootnotty`

Run commands as root without TTY.

```bash
./bin/rootnotty chmod -R 755 /var/www/html/var
```

---

## Magento Commands

### `bin/magento`

Run Magento CLI commands.

```bash
# Flush cache
./bin/magento cache:flush

# Reindex
./bin/magento indexer:reindex

# Deploy static content
./bin/magento setup:static-content:deploy -f

# Run setup upgrade
./bin/magento setup:upgrade

# List all commands
./bin/magento list
```

### `bin/cache-flush`

Quick shortcut to flush Magento cache.

```bash
./bin/cache-flush
```

### `bin/reindex`

Quick shortcut to reindex Magento.

```bash
./bin/reindex
```

### `bin/deploy`

Deploy static content.

```bash
./bin/deploy -f
```

### `bin/di-compile`

Compile dependency injection.

```bash
./bin/di-compile
```

### `bin/setup-upgrade`

Run Magento setup upgrade.

```bash
./bin/setup-upgrade
```

---

## Composer Commands

### `bin/composer`

Run Composer commands in the container.

```bash
# Install dependencies
./bin/composer install

# Update dependencies
./bin/composer update

# Require a package
./bin/composer require vendor/package

# Show outdated packages
./bin/composer outdated
```

---

## Database Commands

### `bin/mysql`

Access MySQL/MariaDB CLI.

```bash
# Interactive shell
./bin/mysql

# Execute a query
./bin/mysql -e "SHOW TABLES;"

# Import a dump
./bin/mysql < dump.sql
```

### `bin/mysqldump`

Dump the database.

```bash
# Dump database to file
./bin/mysqldump > backup.sql

# Dump with options
./bin/mysqldump --single-transaction > backup.sql
```

---

## Cache & Redis

### `bin/redis`

Access Valkey/Redis CLI.

```bash
# Interactive shell
./bin/redis

# List all keys
./bin/redis KEYS "*"

# Flush all databases
./bin/redis FLUSHALL

# Get info
./bin/redis INFO
```

---

## File Operations

### `bin/copyfromcontainer`

Copy files or directories from container to host.

```bash
# Copy vendor directory
./bin/copyfromcontainer vendor

# Copy all files
./bin/copyfromcontainer --all
```

### `bin/copytocontainer`

Copy files or directories from host to container.

```bash
# Copy vendor directory
./bin/copytocontainer vendor

# Copy all files
./bin/copytocontainer --all
```

### `bin/fixowns`

Fix file ownership in the container.

```bash
# Fix all files
./bin/fixowns

# Fix specific path
./bin/fixowns vendor
```

### `bin/fixperms`

Fix file permissions in the container.

```bash
# Fix all files
./bin/fixperms

# Fix specific path
./bin/fixperms var
```

---

## Node.js Commands

### `bin/npm`

Run npm commands in the container.

```bash
./bin/npm install
./bin/npm run build
```

### `bin/node`

Run node commands in the container.

```bash
./bin/node --version
./bin/node script.js
```

### `bin/grunt`

Run grunt commands in the container.

```bash
./bin/grunt watch
./bin/grunt clean
```

---

## Setup Scripts

### `bin/setup`

Initial setup script that:
- Creates the Docker network (`proxy`)
- Copies environment files from templates
- Sets up user permissions (USER_ID, GROUP_ID)
- **Automatically generates SSL certificates** if `SERVER_NAME` is set in `.env`

```bash
./bin/setup
```

**SSL Auto-setup:** If `SERVER_NAME` is defined in your `.env` file, `bin/setup` will automatically call `bin/setup-ssl` to generate trusted SSL certificates for that domain.

### `bin/setup-ssl`

Generate SSL certificates for development using mkcert.

```bash
# Generate certificate for default domain (magento.localhost)
./bin/setup-ssl

# Generate certificate for custom domain
./bin/setup-ssl mystore.localhost
```

This script:
- Installs the local mkcert CA (trusted by your browser)
- Generates SSL certificate and key for the specified domain
- Places certificates in `docker/conf/ssl/` directory
- Shows instructions for configuring docker-compose.yml

After running, update your docker-compose.yml:
```yaml
app:
  environment:
    CADDY_TLS_CONFIG: "/etc/caddy/ssl/magento.localhost.pem /etc/caddy/ssl/magento.localhost-key.pem"
  volumes:
    - ./docker/conf/ssl:/etc/caddy/ssl:ro
```

### `bin/setup-magento`

Interactive Magento installation script. This script prompts for admin settings during setup instead of requiring them in environment files.

```bash
./bin/setup-magento
```

The script will ask for:
- Admin first name and last name
- Admin email
- Admin username and password
- Language, currency, and timezone

All other settings (database, search engine, cache) are read from environment files.

### `bin/uninstall-magento`

Uninstall Magento and remove all data.

```bash
./bin/uninstall-magento
```

This will remove:
- All Magento database tables
- Generated configuration files (app/etc/env.php, app/etc/config.php)
- Generated code and cache

---

## Tips & Best Practices

### Run Commands Without Entering Container

Instead of:
```bash
docker compose exec app bash
# then inside container:
bin/magento cache:flush
exit
```

Use:
```bash
./bin/magento cache:flush
```

### Chain Commands

```bash
./bin/cache-flush && ./bin/reindex
```

### Quick Development Workflow

```bash
# After code changes
./bin/cache-flush && ./bin/di-compile && ./bin/deploy -f
```

### Database Backup Before Upgrade

```bash
./bin/mysqldump > backup-$(date +%Y%m%d).sql
./bin/composer update
./bin/setup-upgrade
```

---

## Troubleshooting

### Permission Issues

```bash
./bin/fixowns
./bin/fixperms
```

### Container Won't Start

```bash
./bin/logs app
./bin/status
```

### Clear Everything and Start Fresh

```bash
./bin/removeall
./bin/start
```
