# Customization Guide

This guide explains how to customize the Magento FrankenPHP Docker stack for your specific needs.

## Table of Contents

- [PHP Extensions](#php-extensions)
- [Custom Hostname](#custom-hostname)
- [Adding Services](#adding-services)
- [Modifying Caddyfile](#modifying-caddyfile)
- [Environment Variables](#environment-variables)
- [Volume Mounts](#volume-mounts)
- [Resource Limits](#resource-limits)
- [Custom Docker Images](#custom-docker-images)

---

## PHP Extensions

### Pre-installed Extensions

The FrankenPHP images include all Magento-required extensions:

```
bcmath, gd, intl, mbstring, opcache, pdo_mysql, soap, xsl, zip, 
sockets, ftp, sodium, redis, apcu
```

### Adding Extensions

To add PHP extensions, create a custom Dockerfile:

```dockerfile
# images/Dockerfile.custom
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-dev

# Install additional extensions
RUN install-php-extensions imagick mongodb

# Or install via pecl
RUN pecl install xhprof && docker-php-ext-enable xhprof
```

Update your docker-compose.yml:

```yaml
services:
  app:
    build:
      context: ./images
      dockerfile: Dockerfile.custom
    # ... rest of config
```

### Configuring PHP Settings

Create a custom PHP configuration:

```ini
# conf/php/custom.ini
memory_limit = 4G
max_execution_time = 600
upload_max_filesize = 64M
post_max_size = 64M
```

Mount it in docker-compose.yml:

```yaml
services:
  app:
    volumes:
      - ./conf/php/custom.ini:/usr/local/etc/php/conf.d/99-custom.ini:ro
```

---

## Custom Hostname

### Single Site

Edit `.env`:

```bash
SERVER_NAME=mystore.localhost
BASE_URL=https://mystore.localhost/
```

### Multiple Hostnames

```bash
# .env
SERVER_NAME="store1.localhost store2.localhost admin.localhost"
```

### With SSL Certificates

```bash
# Generate certificates
./bin/setup-ssl mystore.localhost

# Update .env
CADDY_TLS_CONFIG="/etc/caddy/ssl/mystore.localhost.pem /etc/caddy/ssl/mystore.localhost-key.pem"
```

Mount certificates in docker-compose.yml:

```yaml
services:
  app:
    volumes:
      - ./conf/ssl:/etc/caddy/ssl:ro
```

---

## Adding Services

### Add Elasticsearch (Alternative to OpenSearch)

```yaml
# docker-compose.override.yml
services:
  elasticsearch:
    image: elasticsearch:8.11.0
    container_name: ${PROJECT_NAME:-magento}-elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
    networks:
      - magento
    healthcheck:
      test: ["CMD-SHELL", "curl -sf http://localhost:9200/_cluster/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  elasticsearch-data:
```

### Add Varnish Cache

```yaml
# docker-compose.override.yml
services:
  varnish:
    image: varnish:7.4
    container_name: ${PROJECT_NAME:-magento}-varnish
    volumes:
      - ./conf/varnish/default.vcl:/etc/varnish/default.vcl:ro
    networks:
      - magento
      - proxy
    depends_on:
      - app
    labels:
      - traefik.enable=true
      - traefik.http.routers.varnish.rule=Host(`magento.localhost`)
      - traefik.http.services.varnish.loadbalancer.server.port=80
```

### Add MySQL Instead of MariaDB

```yaml
# docker-compose.override.yml
services:
  mysql:
    image: mysql:8.0
    container_name: ${PROJECT_NAME:-magento}-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-root}
      MYSQL_DATABASE: ${DB_NAME:-magento}
      MYSQL_USER: ${DB_USER:-magento}
      MYSQL_PASSWORD: ${DB_PASSWORD:-magento}
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - magento
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  mysql-data:
```

### Add Redis Instead of Valkey

```yaml
# docker-compose.override.yml
services:
  redis:
    image: redis:7.2-alpine
    container_name: ${PROJECT_NAME:-magento}-redis
    networks:
      - magento
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3
```

---

## Modifying Caddyfile

### Custom Caddyfile Template

Create your own Caddyfile:

```caddy
# conf/Caddyfile.custom
{$SERVER_NAME} {
    # Custom TLS configuration
    {$CADDY_TLS_CONFIG:tls internal}
    
    root * /var/www/html/pub
    
    # Custom headers
    header {
        X-Frame-Options "SAMEORIGIN"
        X-Content-Type-Options "nosniff"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    # Custom rate limiting
    rate_limit {
        zone static {
            key static
            events 100
            window 1s
        }
    }
    
    # Standard Magento routing
    @blocked {
        path *.php
        not path /index.php /get.php /static.php /errors/report.php /errors/404.php /errors/503.php /health_check.php
    }
    respond @blocked 404
    
    @static {
        path /static/*
    }
    handle @static {
        @stRewrite {
            not file {path}
        }
        rewrite @stRewrite /static.php?resource={path}
    }
    
    handle {
        @media {
            path /media/*
        }
        @mediaRewrite {
            not file {path}
        }
        rewrite @media @mediaRewrite /get.php?resource={path}
        
        try_files {path} /index.php?{query}
    }
    
    php_fastcgi unix//run/php/php-fpm.sock
    file_server
    encode gzip
}
```

Mount in docker-compose.yml:

```yaml
services:
  app:
    volumes:
      - ./conf/Caddyfile.custom:/etc/caddy/Caddyfile.template:ro
```

---

## Environment Variables

### All Available Variables

Create a comprehensive `.env` file:

```bash
# Project
PROJECT_NAME=mystore
SERVER_NAME=mystore.localhost
BASE_URL=https://mystore.localhost/

# Magento
MAGENTO_RUN_MODE=developer

# PHP
PHP_MEMORY_LIMIT=4G
PHP_MAX_EXECUTION_TIME=600

# Xdebug
XDEBUG_MODE=debug
XDEBUG_CLIENT_HOST=host.docker.internal
XDEBUG_CLIENT_PORT=9003
XDEBUG_START_WITH_REQUEST=trigger
XDEBUG_IDEKEY=PHPSTORM

# Database
DB_HOST=mariadb
DB_NAME=magento
DB_USER=magento
DB_PASSWORD=magento
MYSQL_ROOT_PASSWORD=root

# Search
OPENSEARCH_HOST=opensearch
OPENSEARCH_PORT=9200

# Cache
VALKEY_HOST=valkey
VALKEY_PORT=6379

# Queue
RABBITMQ_HOST=rabbitmq
RABBITMQ_PORT=5672
RABBITMQ_DEFAULT_USER=magento
RABBITMQ_DEFAULT_PASS=magento

# User permissions
USER_ID=1000
GROUP_ID=1000
```

### Custom Environment Files

Create service-specific env files:

```bash
# env/custom.env
MY_CUSTOM_VAR=value
ANOTHER_VAR=another_value
```

Reference in docker-compose.yml:

```yaml
services:
  app:
    env_file:
      - env/custom.env
```

---

## Volume Mounts

### Development Optimized Mounts

```yaml
# docker-compose.override.yml (macOS/Windows)
services:
  app:
    volumes:
      - type: bind
        source: ./src
        target: /var/www/html
        consistency: cached
```

### Production Optimized Mounts

```yaml
# docker-compose.prod.yml
services:
  app:
    volumes:
      - type: bind
        source: ./src
        target: /var/www/html
        read_only: true
```

### Exclude Directories from Sync

```yaml
services:
  app:
    volumes:
      - ./src:/var/www/html
      - /var/www/html/var
      - /var/www/html/generated
      - /var/www/html/pub/static
```

---

## Resource Limits

### Set Memory and CPU Limits

```yaml
# docker-compose.override.yml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 4G
        reservations:
          cpus: '2'
          memory: 2G
          
  mariadb:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
          
  opensearch:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
    environment:
      - OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g
```

---

## Custom Docker Images

### Production Image with Pre-compiled Assets

```dockerfile
# images/Dockerfile.prod
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-base

# Copy source code
COPY --chown=www-data:www-data ./src /var/www/html

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Compile DI and static content
RUN bin/magento setup:di:compile
RUN bin/magento setup:static-content:deploy -f

# Set production mode
RUN bin/magento deploy:mode:set production --skip-compilation

# Optimize autoloader
RUN composer dump-autoload --optimize

# Set permissions
RUN find var generated pub/static pub/media -type f -exec chmod 664 {} \; \
    && find var generated pub/static pub/media -type d -exec chmod 775 {} \;
```

### Development Image with Extra Tools

```dockerfile
# images/Dockerfile.dev
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-dev

# Install additional dev tools
RUN apt-get update && apt-get install -y \
    vim \
    htop \
    ncdu \
    && rm -rf /var/lib/apt/lists/*

# Install additional PHP tools
RUN composer global require \
    phpstan/phpstan \
    friendsofphp/php-cs-fixer \
    phpmd/phpmd
```

---

## Override Files

Use `docker-compose.override.yml` for local customizations:

```yaml
# docker-compose.override.yml (gitignored)
services:
  app:
    # Your local overrides here
    environment:
      - XDEBUG_MODE=debug,coverage
    volumes:
      - ./custom-config:/etc/custom:ro

  # Add local-only services
  adminer:
    image: adminer
    ports:
      - "8080:8080"
```

---

## Tips & Best Practices

1. **Use override files** - Keep customizations in `docker-compose.override.yml` (gitignored)
2. **Don't modify base images** - Create custom Dockerfiles that extend base images
3. **Use environment variables** - Make configurations flexible via `.env`
4. **Document customizations** - Maintain a README for your specific setup
5. **Test changes** - Validate configs with `docker compose config`

## See Also

- [Architecture Overview](architecture.md)
- [Configuration Guide](configuration.md)
- [Usage Scenarios](usage-scenarios.md)
