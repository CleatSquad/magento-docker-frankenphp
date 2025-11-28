#syntax=docker/dockerfile:1.20
FROM mohelmrabet/magento-frankenphp:php8.2-fp1.10.1-base
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    mkcert \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions xdebug

RUN curl -L -o /usr/local/bin/mhsendmail \
    https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
 && chmod +x /usr/local/bin/mhsendmail

COPY images/php/8.2/conf/mail.ini /usr/local/etc/php/conf.d/zz-mail.ini
COPY images/php/8.2/conf/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY images/php/8.2/conf/disable-opcache.ini /usr/local/etc/php/conf.d/zz-opcache.ini

COPY images/php/common/entrypoint-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV SENDMAIL_PATH=/usr/local/bin/mhsendmail
ENV MAGENTO_RUN_MODE=developer
ENV ENABLE_SSL_DEV=true
