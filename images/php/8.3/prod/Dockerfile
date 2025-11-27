#syntax=docker/dockerfile:1.20
FROM mohelmrabet/magento-frankenphp:php8.3-fp1.10-base
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    msmtp-mta \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG MAGENTO_ROOT=/var/www/html

COPY images/php/8.3/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY --chown=www-data:www-data src/ ${MAGENTO_ROOT}/

COPY images/php/8.3/conf/app.ini /usr/local/etc/php/conf.d/zz-app.ini
COPY images/php/8.3/conf/opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

ENV CADDY_LOG_OUTPUT=stdout
ENV SENDMAIL_PATH=/usr/sbin/sendmail
ENV MAGENTO_RUN_MODE=production

WORKDIR ${MAGENTO_ROOT}

RUN mkdir -p var/cache var/log var/session var/page_cache var/tmp \
    generated/code generated/metadata \
    pub/static pub/media \
 && chown -R www-data:www-data var generated pub/static pub/media \
 && chmod -R 775 var generated pub/static pub/media

USER www-data

RUN composer install --no-interaction --no-progress --prefer-dist --no-dev --optimize-autoloader \
 && composer dump-autoload --no-dev --optimize --apcu


RUN mv app/etc/env.php app/etc/env.php.bak  && php -d memory_limit=4G bin/magento setup:di:compile  && mv app/etc/env.php. bak app/etc/env. php

RUN php -d memory_limit=4G bin/magento setup:static-content:deploy -f --jobs=\$(nproc)

USER www-data

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health_check.php || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint. sh"]
