# Example: Custom Production Dockerfile

This example shows how to create a production-ready Magento Docker image using the FrankenPHP base image.

## Dockerfile.production

```dockerfile
# Use the production-ready base image
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10-base

# Set build arguments
ARG MAGENTO_ROOT=/var/www/html

# Switch to root for installation
USER root

# Install additional production dependencies if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    msmtp-mta \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Magento source code with proper ownership
COPY --chown=www-data:www-data . ${MAGENTO_ROOT}/

# Copy PHP configuration
COPY images/php/8.4/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY images/php/8.4/conf/opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

# Set environment variables
ENV CADDY_LOG_OUTPUT=stdout
ENV SENDMAIL_PATH=/usr/sbin/sendmail
ENV MAGENTO_RUN_MODE=production

WORKDIR ${MAGENTO_ROOT}

# Create required directories
RUN mkdir -p var/cache var/log var/session var/page_cache var/tmp \
    generated/code generated/metadata \
    pub/static pub/media \
 && chown -R www-data:www-data var generated pub/static pub/media \
 && chmod -R 775 var generated pub/static pub/media

# Switch to www-data user for build steps
USER www-data

# Install Composer dependencies without dev packages
RUN composer install \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --no-dev \
    --optimize-autoloader \
 && composer dump-autoload --no-dev --optimize --apcu

# Compile DI (Dependency Injection)
RUN mv app/etc/env.php app/etc/env.php.bak \
 && php -d memory_limit=4G bin/magento setup:di:compile \
 && mv app/etc/env.php.bak app/etc/env.php

# Deploy static content
RUN php -d memory_limit=4G bin/magento setup:static-content:deploy -f --jobs=16

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health_check.php || exit 1

# Set entrypoint
ENTRYPOINT ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
```

## Build Commands

```bash
# Build the production image
docker build -f Dockerfile.production -t my-magento-store:latest .

# Run the container
docker run -d \
  --name magento-prod \
  -p 80:80 \
  -p 443:443 \
  -e SERVER_NAME=mystore.example.com \
  my-magento-store:latest
```

## Multi-stage Build (Recommended)

For smaller production images, use a multi-stage build:

```dockerfile
# Stage 1: Build
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10-dev AS builder

WORKDIR /var/www/html
COPY --chown=www-data:www-data . .

USER www-data
RUN composer install --no-dev --optimize-autoloader
RUN php -d memory_limit=4G bin/magento setup:di:compile
RUN php -d memory_limit=4G bin/magento setup:static-content:deploy -f --jobs=16

# Stage 2: Production
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10-base

WORKDIR /var/www/html
COPY --from=builder --chown=www-data:www-data /var/www/html .

ENV MAGENTO_RUN_MODE=production

USER www-data
ENTRYPOINT ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
```
