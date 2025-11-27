#syntax=docker/dockerfile:1.20
FROM dunglas/frankenphp:1.10.0-php8.3
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

RUN apt-get update && apt-get install -y --no-install-recommends \
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
 && apt-get clean && rm -rf /var/lib/apt/lists/*

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
        apcu

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Create caddy config directory
RUN mkdir -p /etc/caddy /data/caddy /var/www/html \
 && chown -R www-data:www-data /var/www /data /etc/caddy

# Copy default Caddyfile
COPY images/php/8.3/conf/Caddyfile /etc/caddy/Caddyfile


ENV CADDY_LOG_OUTPUT=stdout
ENV COMPOSER_ALLOW_SUPERUSER=0
ENV COMPOSER_HOME=/var/www/.composer

WORKDIR /var/www/html

EXPOSE 80 443
