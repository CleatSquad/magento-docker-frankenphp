#syntax=docker/dockerfile:1.20
FROM mohelmrabet/magento-frankenphp-base:php8.4-fp1.10
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

USER root
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

COPY ./images/php/8.4/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Fix directory permissions
RUN mkdir -p /data/caddy \
    && chown -R www-data:www-data /var/www /data

COPY --chown=www-data:www-data src/ /var/www/html/

WORKDIR /var/www/html
USER www-data

RUN chmod +x bin/magento
#RUN bin/magento setup:static-content:deploy -f -j "$(nproc)"
#RUN bin/magento setup:di:compile

# PHP app config for PROD
COPY images/php/8.4/conf/app-prod.ini /usr/local/etc/php/conf.d/zz-app.ini

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install \
    --no-interaction --no-progress \
    --prefer-dist --no-dev --optimize-autoloader

RUN COMPOSER_ALLOW_SUPERUSER=1 composer dump-autoload --no-dev --optimize --apcu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
