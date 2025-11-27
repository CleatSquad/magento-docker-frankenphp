#syntax=docker/dockerfile:1.20
FROM dunglas/frankenphp:1.10.0-php8.2
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

RUN mkdir -p /etc/caddy /data/caddy /var/www/html /var/www/. composer \
 && chown -R www-data:www-data /var/www /data /etc/caddy

COPY images/php/8.2/conf/Caddyfile /etc/caddy/Caddyfile
COPY images/php/8.2/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY images/php/8.2/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini

ENV CADDY_LOG_OUTPUT=stdout
ENV COMPOSER_ALLOW_SUPERUSER=0
ENV COMPOSER_HOME=/var/www/.composer

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
