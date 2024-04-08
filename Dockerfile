#syntax=docker/dockerfile:1.4

# Versions
FROM dunglas/frankenphp:1-php8.2 AS frankenphp_upstream

# The different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# Base FrankenPHP image
FROM frankenphp_upstream AS frankenphp_base

WORKDIR /var/www/html

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
	git \
    acl \
	&& rm -rf /var/lib/apt/lists/* \

RUN set -eux; \
	install-php-extensions \
		@composer \
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
	;

# Copy the application code
COPY --link frankenphp/conf.d/app.ini $PHP_INI_DIR/conf.d/
COPY --link --chmod=755 frankenphp/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --link frankenphp/Caddyfile /etc/caddy/Caddyfile

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f https://$SERVER_NAME/health_check.php || exit 1
CMD [ "frankenphp", "run", "--config", "/etc/caddy/Caddyfile" ]

# Development FrankenPHP image
FROM frankenphp_base AS frankenphp_dev

ENV MAGE_MODE=developer XDEBUG_MODE=off

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN apt-get update && apt-get install -y --no-install-recommends mkcert

RUN set -eux; \
	install-php-extensions \
		xdebug \
	;

COPY --link frankenphp/conf.d/app.dev.ini $PHP_INI_DIR/conf.d/
CMD [ "frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--watch" ]
