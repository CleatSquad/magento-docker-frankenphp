# Production Dockerfile for Magento 2 with FrankenPHP
# This Dockerfile builds a production-ready image with compiled DI and static content
#
# Usage:
#   docker build -f Dockerfile.prod -t my-magento-store:latest .
#   docker run -d -p 80:80 -p 443:443 -e SERVER_NAME=mystore.com my-magento-store:latest
#
# Configuration via build arguments:
#   docker build --build-arg STATIC_CONTENT_THEMES="Magento/blank Vendor/Theme" \
#                --build-arg STATIC_CONTENT_LANGUAGES="en_US fr_FR" ...

# Stage 1: Build
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-base AS builder

ARG MAGENTO_ROOT=/var/www/html
# Static content deployment configuration
ARG STATIC_CONTENT_THEMES="Magento/blank Magento/luma"
ARG STATIC_CONTENT_ADMINHTML_THEME="Magento/backend"
ARG STATIC_CONTENT_LANGUAGES="en_US"
ARG SCD_THREADS=5
ARG SCD_STRATEGY="compact"

USER root

WORKDIR ${MAGENTO_ROOT}

# Copy Magento source code
COPY --chown=www-data:www-data . ${MAGENTO_ROOT}/

# Create required directories
RUN mkdir -p var/cache var/log var/session var/page_cache var/tmp \
    generated/code generated/metadata \
    pub/static pub/media \
 && chown -R www-data:www-data var generated pub/static pub/media \
 && chmod -R 775 var generated pub/static pub/media

USER www-data

# Clean caches, install dependencies, and compile DI
# hadolint ignore=DL3059
ARG BASE_URL="http://localhost/"
RUN rm -rf var/cache/* var/page_cache/* generated/code/* generated/metadata/* pub/static/* \
 && composer install \
        --no-interaction \
        --no-progress \
        --prefer-dist \
        --no-dev \
        --optimize-autoloader \
 && composer dump-autoload --no-dev --optimize --apcu \
 # Backup env.php to avoid database issues during DI compile
 && if [ -f app/etc/env.php ]; then mv app/etc/env.php app/etc/env.php.bak; fi \
 && php -d memory_limit=4G bin/magento setup:di:compile \
 # Create minimal env.php for static content deployment (no external services needed)
 && printf '%s\n' \
        '<?php' \
        'return [' \
        "    'backend' => ['frontName' => 'admin']," \
        "    'cache_types' => []," \
        "    'cache' => ['frontend' => ['default' => ['backend' => 'Magento\\Framework\\Cache\\Backend\\File']]]," \
        "    'MAGE_MODE' => 'production'," \
        "    'scopes' => [" \
        "        'websites' => ['base' => ['website_id' => '1', 'code' => 'base', 'name' => 'Main Website', 'sort_order' => '0', 'default_group_id' => '1', 'is_default' => '1']]," \
        "        'groups' => ['1' => ['group_id' => '1', 'website_id' => '1', 'code' => 'main_website_store', 'name' => 'Main Website Store', 'root_category_id' => '2', 'default_store_id' => '1']]," \
        "        'stores' => ['default' => ['store_id' => '1', 'code' => 'default', 'website_id' => '1', 'group_id' => '1', 'name' => 'Default Store View', 'sort_order' => '0', 'is_active' => '1']]," \
        "    ]," \
        "    'system' => ['default' => ['web' => ['unsecure' => ['base_url' => '${BASE_URL}'], 'secure' => ['base_url' => '${BASE_URL}']]]]," \
        '];' > app/etc/env.php \
 # Deploy static content using direct theme/area specification
 && THEME_ARGS=""; \
    for theme in ${STATIC_CONTENT_THEMES}; do THEME_ARGS="$THEME_ARGS --theme=$theme"; done; \
    php -d memory_limit=4G bin/magento setup:static-content:deploy -f \
        --jobs="${SCD_THREADS}" \
        --strategy="${SCD_STRATEGY}" \
        --area=frontend ${THEME_ARGS} \
        --area=adminhtml --theme="${STATIC_CONTENT_ADMINHTML_THEME}" \
        --language="${STATIC_CONTENT_LANGUAGES}" \
 # Restore env.php after static content deployment for runtime
 && if [ -f app/etc/env.php.bak ]; then mv app/etc/env.php.bak app/etc/env.php; fi

# Stage 2: Production image
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-base

ARG MAGENTO_ROOT=/var/www/html

WORKDIR ${MAGENTO_ROOT}

# Copy built application from builder stage
COPY --from=builder --chown=www-data:www-data ${MAGENTO_ROOT} ${MAGENTO_ROOT}

# Set production environment
ENV MAGENTO_RUN_MODE=production \
    CADDY_LOG_OUTPUT=stdout

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health_check.php || exit 1

USER www-data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
