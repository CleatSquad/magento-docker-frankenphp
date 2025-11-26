#syntax=docker/dockerfile:1.20
FROM mohelmrabet/magento-frankenphp-base:php8.4-fp1.10
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

USER root
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

COPY ./images/php/8.4/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# --- ADD SENDMAIL ---
# Install sendmail for local mail submission only; disable the daemon to prevent open relay risks.
RUN apt-get update && \
    apt-get install -y sendmail sendmail-bin && \
    rm -rf /var/lib/apt/lists/* && \
    if [ -x /etc/init.d/sendmail ]; then rm /etc/init.d/sendmail; fi && \
    if [ -f /lib/systemd/system/sendmail.service ]; then rm /lib/systemd/system/sendmail.service; fi
# NOTE: Magento should use an SMTP module for actual email delivery. The sendmail daemon is disabled for security.

# Fix directory permissions
RUN mkdir -p /data/caddy \
    && chown -R www-data:www-data /var/www /data

# Ensure Caddy logs go to stdout
ENV CADDY_LOG_OUTPUT=stdout
ARG MAGENTO_ROOT=/var/www/html

# Use the real sendmail binary
ENV SENDMAIL_PATH=/usr/sbin/sendmail

COPY --chown=www-data:www-data src/ /var/www/html/

WORKDIR /var/www/html
USER www-data

RUN chmod +x bin/magento

# PHP app config for PROD
COPY images/php/8.4/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY images/php/8.4/conf/opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

RUN COMPOSER_ALLOW_SUPERUSER=1 composer install \
    --no-interaction --no-progress \
    --prefer-dist --no-dev --optimize-autoloader

RUN COMPOSER_ALLOW_SUPERUSER=1 composer dump-autoload --no-dev --optimize --apcu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
