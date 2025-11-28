#syntax=docker/dockerfile:1.20
FROM dunglas/frankenphp:1.10.1-php8.3
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

# combine package installation and cleanup in a single layer
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
    && rm -rf /var/lib/apt/lists/*

# install php extensions in one step
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

# copy composer from official image (pin tag if needed)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# set up app dir and ownership in one go
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
RUN mkdir -p /etc/caddy /data/caddy /var/www/html /var/www/.composer \
    && chown -R www-data:www-data /var/www /data /etc/caddy

COPY --chown=www-data:www-data images/php/common/Caddyfile.template /etc/caddy/Caddyfile.template
COPY images/php/common/entrypoint-base.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY images/php/8.3/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini

ENV CADDY_LOG_OUTPUT=stdout \
    COMPOSER_ALLOW_SUPERUSER=0 \
    COMPOSER_HOME=/var/www/.composer

WORKDIR /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp
EXPOSE 2019

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# optional healthcheck
HEALTHCHECK --interval=30s --timeout=5s CMD curl -f http://localhost/ || exit 1
