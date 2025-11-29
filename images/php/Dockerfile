#syntax=docker/dockerfile:1.20
# Consolidated Dockerfile for Magento FrankenPHP
# Supports base, dev, and prod build targets via BUILD_TYPE ARG
#
# Build examples:
#   docker build --build-arg BUILD_TYPE=base -t magento-frankenphp:base .
#   docker build --build-arg BUILD_TYPE=dev -t magento-frankenphp:dev .
#   docker build --build-arg BUILD_TYPE=prod -t magento-frankenphp:prod .

ARG PHP_VERSION=8.4
ARG FRANKENPHP_VERSION=1.10.1
ARG BUILD_TYPE=base

FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION} AS base
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

# Combine package installation and cleanup in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron \
      libfreetype6-dev \
      libicu-dev \
      libjpeg62-turbo-dev \
      libpng-dev \
      libwebp-dev \
      libxslt1-dev \
      zip \
      acl \
      libnss3-tools \
      curl \
      unzip \
      default-mysql-client \
      gosu \
      gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Note: gettext-base provides envsubst used in entrypoint scripts for Xdebug config

# Install PHP extensions in one step
RUN set -eux; \
    install-php-extensions \
      bcmath \
      gd \
      intl \
      mbstring \
      opcache \
      pdo_mysql \
      soap \
      xsl \
      zip \
      sockets \
      ftp \
      sodium \
      redis \
      apcu \
    && true

# Copy composer from official image
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set up app dir and ownership
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
RUN mkdir -p /etc/caddy /data/caddy /var/www/html /var/www/.composer /etc/php \
    && chown -R www-data:www-data /var/www /data /etc/caddy \
    && chown root:root /etc/php

COPY --chown=www-data:www-data images/php/common/Caddyfile.template /etc/caddy/Caddyfile.template
COPY images/php/common/entrypoint-base.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy PHP configuration from common
COPY images/php/common/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY images/php/common/conf/opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

ENV CADDY_LOG_OUTPUT=stdout \
    COMPOSER_ALLOW_SUPERUSER=0 \
    COMPOSER_HOME=/var/www/.composer

WORKDIR /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Optional healthcheck
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost/ || exit 1

FROM base AS dev

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    mkcert \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions xdebug

RUN curl -L -o /usr/local/bin/mhsendmail \
    https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
 && chmod +x /usr/local/bin/mhsendmail

# Copy PHP dev configuration from common
COPY images/php/common/conf/mail.ini /usr/local/etc/php/conf.d/zz-mail.ini
COPY images/php/common/conf/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY images/php/common/conf/disable-opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

COPY images/php/common/entrypoint-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV SENDMAIL_PATH=/usr/local/bin/mhsendmail \
    MAGENTO_RUN_MODE=developer \
    ENABLE_SSL_DEV=true \
    XDEBUG_MODE=debug \
    XDEBUG_CLIENT_HOST=host.docker.internal \
    XDEBUG_CLIENT_PORT=9003 \
    XDEBUG_START_WITH_REQUEST=trigger \
    XDEBUG_IDEKEY=PHPSTORM

FROM base AS prod

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    msmtp-mta \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG MAGENTO_ROOT=/var/www/html

COPY images/php/common/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY --chown=www-data:www-data src/ ${MAGENTO_ROOT}/

ENV CADDY_LOG_OUTPUT=stdout \
    SENDMAIL_PATH=/usr/sbin/sendmail \
    MAGENTO_RUN_MODE=production

WORKDIR ${MAGENTO_ROOT}

RUN mkdir -p var/cache var/log var/session var/page_cache var/tmp \
    generated/code generated/metadata \
    pub/static pub/media \
 && chown -R www-data:www-data var generated pub/static pub/media \
 && chmod -R 775 var generated pub/static pub/media

USER www-data

RUN composer install --no-interaction --no-progress --prefer-dist --no-dev --optimize-autoloader \
 && composer dump-autoload --no-dev --optimize --apcu

RUN if [ -f app/etc/env.php ]; then \
        cp app/etc/env.php app/etc/env.php.bak && \
        php -d memory_limit=4G bin/magento setup:di:compile && \
        mv app/etc/env.php.bak app/etc/env.php; \
    else \
        php -d memory_limit=4G bin/magento setup:di:compile; \
    fi

RUN php -d memory_limit=4G bin/magento setup:static-content:deploy -f --jobs=16

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health_check.php || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

FROM ${BUILD_TYPE} AS final
