#!/bin/bash

IMAGE="mohelmrabet/magento-frankenphp"

# Create directories
for version in 8.2 8.3 8.4; do
    mkdir -p images/php/${version}/{base,dev,prod,conf}
done

# Generate BASE Dockerfile for each version
for version in 8.2 8.3 8.4; do
cat > "images/php/${version}/base/Dockerfile" << DOCKERFILE
#syntax=docker/dockerfile:1.20
FROM dunglas/frankenphp:1.10.0-php${version}
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

RUN apt-get update && apt-get install -y --no-install-recommends \\
    cron \\
    libfreetype6-dev \\
    libicu-dev \\
    libjpeg62-turbo-dev \\
    libpng-dev \\
    libwebp-dev \\
    libxslt1-dev \\
    zip \\
    acl \\
    libnss3-tools \\
    curl \\
    unzip \\
    default-mysql-client \\
    gosu \\
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -eux; \\
    install-php-extensions \\
        bcmath \\
        gd \\
        intl \\
        mbstring \\
        opcache \\
        pdo_mysql \\
        soap \\
        xsl \\
        zip \\
        sockets \\
        ftp \\
        sodium \\
        redis \\
        apcu

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

RUN mkdir -p /data/caddy /var/www/html \\
 && chown -R www-data:www-data /var/www /data

ENV CADDY_LOG_OUTPUT=stdout
ENV COMPOSER_ALLOW_SUPERUSER=0
ENV COMPOSER_HOME=/var/www/.composer

WORKDIR /var/www/html

EXPOSE 80 443
DOCKERFILE
done

# Generate DEV Dockerfile for each version
for version in 8.2 8.3 8.4; do
cat > "images/php/${version}/dev/Dockerfile" << DOCKERFILE
#syntax=docker/dockerfile:1.20
FROM ${IMAGE}:php${version}-fp1.10-base
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \\
    git \\
    mkcert \\
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions xdebug

RUN curl -L -o /usr/local/bin/mhsendmail \\
    https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \\
 && chmod +x /usr/local/bin/mhsendmail

RUN mkdir -p /var/www/html /data/caddy \\
 && chown -R www-data:www-data /var/www /data

ENV CADDY_LOG_OUTPUT=stdout
ENV SENDMAIL_PATH=/usr/local/bin/mhsendmail
ENV MAGENTO_RUN_MODE=developer

COPY images/php/${version}/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY images/php/${version}/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY images/php/${version}/conf/mail.ini /usr/local/etc/php/conf.d/zz-mail.ini
COPY images/php/${version}/conf/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
DOCKERFILE
done

# Generate PROD Dockerfile for each version
for version in 8.2 8.3 8.4; do
cat > "images/php/${version}/prod/Dockerfile" << DOCKERFILE
#syntax=docker/dockerfile:1.20
FROM ${IMAGE}:php${version}-fp1.10-base
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \\
    msmtp-mta \\
 && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG MAGENTO_ROOT=/var/www/html

COPY images/php/${version}/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY --chown=www-data:www-data src/ \${MAGENTO_ROOT}/

COPY images/php/${version}/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY images/php/${version}/conf/opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

ENV CADDY_LOG_OUTPUT=stdout
ENV SENDMAIL_PATH=/usr/sbin/sendmail
ENV MAGENTO_RUN_MODE=production

WORKDIR \${MAGENTO_ROOT}

RUN mkdir -p var/cache var/log var/session var/page_cache var/tmp \\
    generated/code generated/metadata \\
    pub/static pub/media \\
 && chown -R www-data:www-data var generated pub/static pub/media \\
 && chmod -R 775 var generated pub/static pub/media

USER www-data

RUN composer install --no-interaction --no-progress --prefer-dist --no-dev --optimize-autoloader \\
 && composer dump-autoload --no-dev --optimize --apcu

RUN php -d memory_limit=4G bin/magento setup:di:compile

RUN php -d memory_limit=4G bin/magento setup:static-content:deploy -f --jobs=\\\$(nproc)

USER root
RUN chmod -R 775 var generated pub/static pub/media
USER www-data

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \\
  CMD curl -f http://localhost/health_check.php || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint. sh"]
DOCKERFILE
done

# Generate config files for each version
for version in 8.2 8.3 8.4; do

cat > "images/php/${version}/conf/app.ini" << 'EOF'
memory_limit = 2G
max_execution_time = 1800
realpath_cache_size = 10M
realpath_cache_ttl = 7200
max_input_vars = 10000
post_max_size = 64M
upload_max_filesize = 64M
date.timezone = Europe/Paris
EOF

cat > "images/php/${version}/conf/opcache.ini" << 'EOF'
opcache.enable = 1
opcache.memory_consumption = 512
opcache.interned_strings_buffer = 64
opcache.max_accelerated_files = 130986
opcache.validate_timestamps = 0
opcache.save_comments = 1
EOF

cat > "images/php/${version}/conf/mail.ini" << 'EOF'
sendmail_path = /usr/local/bin/mhsendmail
EOF

cat > "images/php/${version}/conf/xdebug.ini" << 'EOF'
xdebug.mode = debug
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
xdebug.start_with_request = trigger
xdebug.idekey = PHPSTORM
EOF

cat > "images/php/${version}/entrypoint.sh" << 'EOF'
#!/bin/bash
set -e

if [ -n "$USER_ID" ] && [ "$USER_ID" != "1000" ]; then
    echo "Changing www-data UID to $USER_ID..."
    usermod -u $USER_ID www-data 2>/dev/null || true
fi

if [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "1000" ]; then
    echo "Changing www-data GID to $GROUP_ID..."
    groupmod -g $GROUP_ID www-data 2>/dev/null || true
fi

if [ -n "$USER_ID" ] || [ -n "$GROUP_ID" ]; then
    chown -R www-data:www-data /var/www /data 2>/dev/null || true
fi

exec gosu www-data frankenphp run --config /etc/caddy/Caddyfile
EOF
chmod +x "images/php/${version}/entrypoint.sh"

cat > "images/php/${version}/entrypoint-prod.sh" << 'EOF'
#!/bin/bash
set -e
exec gosu www-data frankenphp run --config /etc/caddy/Caddyfile
EOF
chmod +x "images/php/${version}/entrypoint-prod.sh"

done

echo "✅ All files generated for PHP 8.1, 8.2, 8. 3, 8.4"