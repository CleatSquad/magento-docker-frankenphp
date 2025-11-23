#syntax=docker/dockerfile:1.20
FROM dunglas/frankenphp:1.10.0-php8.4
LABEL maintainer="Mohamed El Mrabet <contact@cleatsquad.dev>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    cron \
    sendmail-bin \
    sendmail \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libxslt1-dev \
    zip \
    acl \
    libnss3-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    install-php-extensions \
        bcmath \
        gd \
        intl \
        mbstring \
        mcrypt \
        opcache \
        pdo_mysql \
        soap \
        xsl \
        zip \
        sockets \
        ftp \
        sodium

WORKDIR /var/www/html

COPY entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
