# Magento FrankenPHP Docker Images
# <img src="https://frankenphp.dev/img/logo_darkbg.svg" width="180" />

🚀 High-performance Docker images for Magento 2 with [FrankenPHP](https://frankenphp.dev/).

## Supported Tags

| Tag | PHP | Type | Description |
|-----|-----|------|-------------|
| `php8.4-fp1.10.1-base` | 8.4 | Base | Production ready |
| `php8.4-fp1.10.1-dev` | 8.4 | Dev | With Xdebug |
| `php8.3-fp1.10.1-base` | 8.3 | Base | Production ready |
| `php8.3-fp1.10.1-dev` | 8.3 | Dev | With Xdebug |
| `php8.2-fp1.10.1-base` | 8.2 | Base | Production ready |
| `php8.2-fp1.10.1-dev` | 8.2 | Dev | With Xdebug |
| `latest` | 8.4 | Base | Default |
| `base` | 8.4 | Base | Alias |
| `dev` | 8.4 | Dev | Alias |

## Quick Start

### Development

```yaml
services:
  app:
    image: mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-dev
    environment:
      - USER_ID=1000
      - GROUP_ID=1000
    volumes:
      - ./src:/var/www/html
    ports:
      - "80:80"
      - "443:443"
```

### Production

```dockerfile
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-base

COPY --chown=www-data:www-data . /var/www/html/

USER www-data
RUN composer install --no-dev --optimize-autoloader
RUN bin/magento setup:di:compile
RUN bin/magento setup:static-content:deploy -f
```

## Features

### Base Image
- ✅ PHP 8.2, 8.3, 8.4
- ✅ FrankenPHP 1.10.1
- ✅ All Magento PHP extensions
- ✅ Composer 2
- ✅ OPcache optimized

### Dev Image
- ✅ Everything in Base +
- ✅ Xdebug 3
- ✅ mkcert (local HTTPS)
- ✅ Self-signed SSL certificates (auto-generated)
- ✅ git
- ✅ Mailhog support
- ✅ Runtime UID/GID mapping

## PHP Extensions

```
bcmath, gd, intl, mbstring, opcache, pdo_mysql, soap, xsl, zip, sockets, ftp, sodium, redis, apcu
```

## Environment Variables (Dev)

| Variable | Default | Description |
|----------|---------|-------------|
| `USER_ID` | `1000` | UID for www-data |
| `GROUP_ID` | `1000` | GID for www-data |
| `MAGENTO_RUN_MODE` | `developer` | Magento mode |
| `SERVER_NAME` | `localhost` | Server hostname for SSL |
| `ENABLE_SSL_DEV` | `true` | Enable self-signed SSL |

## Xdebug Configuration (Dev)

Xdebug can be configured via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `XDEBUG_MODE` | `debug` | Xdebug mode (debug, coverage, develop, profile, trace, off) |
| `XDEBUG_CLIENT_HOST` | `host.docker.internal` | IDE host address |
| `XDEBUG_CLIENT_PORT` | `9003` | IDE listening port |
| `XDEBUG_START_WITH_REQUEST` | `trigger` | When to start debugging (trigger, yes, no) |
| `XDEBUG_IDEKEY` | `PHPSTORM` | IDE key for session identification |

Example:

```yaml
services:
  app:
    image: mohelmrabet/magento-frankenphp:dev
    environment:
      XDEBUG_MODE: debug
      XDEBUG_CLIENT_HOST: host.docker.internal
      XDEBUG_CLIENT_PORT: 9003
```

## Caddyfile Configuration

The Caddyfile can be customized by mounting your own template:

```yaml
volumes:
  - ./my-Caddyfile.template:/etc/caddy/Caddyfile.template:ro
```

See the [Caddyfile Configuration Guide](https://github.com/CleatSquad/magento-docker-frankenphp/blob/main/docs/Caddyfile.md) for detailed documentation.

## Links

- 📦 [GitHub](https://github.com/CleatSquad/magento-docker-frankenphp)
- 🚀 [FrankenPHP](https://frankenphp.dev/)
