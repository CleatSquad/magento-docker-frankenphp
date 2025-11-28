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

## Links

- 📦 [GitHub](https://github.com/CleatSquad/magento-docker-frankenphp)
- 🚀 [FrankenPHP](https://frankenphp.dev/)
