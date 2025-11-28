# Magento 2 Docker + FrankenPHP

> Production-ready Docker environment for Magento 2 with FrankenPHP — the modern, high-performance PHP application server

<p align="center">
  <img src="https://frankenphp.dev/img/logo_darkbg.svg" width="150" alt="FrankenPHP Logo" />
</p>

<p align="center">
  <a href="https://hub.docker.com/r/mohelmrabet/magento-frankenphp"><img src="https://img.shields.io/docker/pulls/mohelmrabet/magento-frankenphp.svg?logo=docker" alt="Docker Pulls" /></a>
  <img src="https://img.shields.io/badge/magento-2.4.x-orange.svg?logo=magento" alt="Magento 2.4.x" />
  <img src="https://img.shields.io/badge/php-8.2%20|%208.3%20|%208.4-blue.svg?logo=php" alt="PHP Versions" />
  <img src="https://img.shields.io/badge/frankenphp-1.10-purple.svg" alt="FrankenPHP 1.10" />
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License MIT" /></a>
</p>

---

## Why FrankenPHP for Magento?

| Feature | FrankenPHP | PHP-FPM + Nginx |
|---------|------------|-----------------|
| **Performance** | ~2500 req/s | ~1800 req/s |
| **Memory** | Lower | Higher |
| **Setup** | Single binary | Multiple services |
| **HTTPS** | Automatic (Caddy) | Manual config |

## Quick Start

```bash
# 1. Clone
git clone https://github.com/mohelmrabet/magento-frankenphp.git
cd magento-frankenphp

# 2. Setup
./bin/setup

# 3. Start
docker compose up -d

# 4. Access https://magento.localhost
```

## Docker Images

```bash
# Production
docker pull mohelmrabet/magento-frankenphp:latest

# Development (with Xdebug)
docker pull mohelmrabet/magento-frankenphp:dev
```

| Tag | PHP | Use Case |
|-----|-----|----------|
| `php8.4-fp1.10-base` / `latest` | 8.4 | Production |
| `php8.4-fp1.10-dev` / `dev` | 8.4 | Development |
| `php8.3-fp1.10-base` | 8.3 | Production |
| `php8.3-fp1.10-dev` | 8.3 | Development |
| `php8.2-fp1.10-base` | 8.2 | Production |
| `php8.2-fp1.10-dev` | 8.2 | Development |

## Features

- ✅ **PHP 8.2, 8.3, 8.4** — All Magento-required extensions included
- ✅ **Automatic HTTPS** — Via Caddy/Let's Encrypt
- ✅ **Xdebug ready** — Pre-configured in dev images
- ✅ **Full stack included** — MariaDB, OpenSearch, Valkey, RabbitMQ, Mailhog
- ✅ **CLI tools** — Convenient scripts in `bin/` directory

## Documentation

| Guide | Description |
|-------|-------------|
| 📖 [Getting Started](docs/getting-started.md) | Installation and initial setup |
| 🛠️ [CLI Tools](docs/CLI.md) | All available commands |
| ⚙️ [Configuration](docs/configuration.md) | Environment variables and settings |
| 🌐 [Caddyfile](docs/Caddyfile.md) | Web server configuration |
| 🚀 [Production](examples/production-dockerfile.md) | Production deployment |
| 💻 [Local Dev](examples/local-development.md) | Development environment setup |
| ☸️ [Kubernetes](examples/kubernetes-deployment.md) | K8s deployment guide |

## Common Commands

```bash
./bin/start              # Start containers
./bin/stop               # Stop containers
./bin/magento cache:flush
./bin/composer install
./bin/mysql              # Database CLI
```

See [CLI Documentation](docs/CLI.md) for all commands.

## Requirements

- Docker >= 24.0
- Docker Compose >= 2.20
- Git

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT — see [LICENSE](LICENSE.txt)

## Links

- 📦 [Docker Hub](https://hub.docker.com/r/mohelmrabet/magento-frankenphp)
- 🚀 [FrankenPHP](https://frankenphp.dev/)
- 🛒 [Magento 2](https://business.adobe.com/products/magento/magento-commerce.html)
- 📝 [Changelog](CHANGELOG.md)
