# Magento 2 + FrankenPHP — Complete Docker Environment

### MariaDB · OpenSearch · Valkey · Mailhog · RabbitMQ

<p align="center">
  <img src="https://frankenphp.dev/img/logo_darkbg.svg" width="180" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/magento-2.4.x-brightgreen.svg?logo=magento" />
  <img src="https://img.shields.io/badge/php-8.2%20|%208.3%20|%208.4-blue.svg?logo=php" />
  <img src="https://img.shields.io/badge/frankenphp-1.10-purple.svg" />
  <a href="https://hub.docker.com/r/mohelmrabet/magento-frankenphp"><img src="https://img.shields.io/docker/pulls/mohelmrabet/magento-frankenphp.svg" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>
</p>

---

A high-performance Docker environment for **Magento 2** powered by **FrankenPHP**.

## ✨ Features

- 🚀 **FrankenPHP** — Modern PHP app server with Caddy
- 🐘 **PHP 8.2, 8.3, 8.4** — Multi-version support
- 🔒 **Automatic HTTPS** — Via Caddy/Let's Encrypt
- ⚡ **Optimized for Magento** — All extensions pre-installed
- 🛠️ **Dev & Prod images** — Xdebug included in dev
- 📦 **Ready to use** — Just pull and run

---

## 🐳 Docker Hub

```bash
# Base (production)
docker pull mohelmrabet/magento-frankenphp:php8.4-fp1.10-base

# Dev (with Xdebug)
docker pull mohelmrabet/magento-frankenphp:php8.4-fp1.10-dev
```

### Available Tags

| Tag | PHP | Type | Description |
|-----|-----|------|-------------|
| `php8.4-fp1.10-base` | 8.4 | Base | Production ready |
| `php8.4-fp1.10-dev` | 8.4 | Dev | With Xdebug |
| `php8.3-fp1.10-base` | 8.3 | Base | Production ready |
| `php8.3-fp1.10-dev` | 8.3 | Dev | With Xdebug |
| `php8.2-fp1.10-base` | 8.2 | Base | Production ready |
| `php8.2-fp1.10-dev` | 8.2 | Dev | With Xdebug |
| `latest` | 8.4 | Base | Alias for php8.4-fp1.10-base |
| `dev` | 8.4 | Dev | Alias for php8.4-fp1.10-dev |

---

## 🔧 Prerequisites

- **Docker** >= 24.0
- **Docker Compose** >= 2.20
- **Git**

---

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/mohelmrabet/magento-frankenphp.git
cd magento-frankenphp
```

### 2. Run the setup script

```bash
./bin/setup.sh
```

This script will:
- ✅ Create the `proxy` Docker network
- ✅ Copy environment files from templates
- ✅ Set your user ID/GID for proper file permissions

### 3. Start containers

```bash
# Development
docker compose up -d

# Production
docker compose -f docker-compose.prod.yml up -d
```

### 4. Access

| Service | URL |
|---------|-----|
| Magento | https://magento.localhost |
| Mailhog | http://mailhog.localhost |
| RabbitMQ | http://rabbit.localhost |
| phpMyAdmin | http://myadmin.localhost |

---

## 📦 Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| **app** | mohelmrabet/magento-frankenphp | 80, 443 | FrankenPHP + Caddy |
| **mariadb** | mariadb:11.4 | 3306 | Database |
| **opensearch** | opensearch:2.x | 9200 | Search engine |
| **valkey** | valkey:8.1 | 6379 | Cache & Sessions |
| **rabbitmq** | rabbitmq:4.1 | 5672, 15672 | Message queue |
| **mailhog** | mailhog | 8025 | Email catcher (dev) |

---

## 📁 Project Structure

```
magento-docker-frankenphp/
├── .github/
│   └── workflows/
│       └── ci.yml                # CI/CD workflow
├── bin/
│   └── setup.sh                  # Environment setup script
├── conf/
│   └── traefik.yml               # Traefik configuration
├── env/
│   ├── magento.env.example       # Magento environment template
│   ├── mariadb.env.example       # MariaDB environment template
│   ├── opensearch.env.example    # OpenSearch environment template
│   ├── rabbitmq.env.example      # RabbitMQ environment template
│   └── valkey.env.example        # Valkey environment template
├── examples/
│   ├── kubernetes-deployment.md  # Kubernetes deployment guide
│   ├── local-development.md      # Local development guide
│   └── production-dockerfile.md  # Production Dockerfile example
├── images/
│   ├── opensearch/
│   │   └── Dockerfile            # OpenSearch with plugins
│   ├── rabbitmq/
│   │   └── rabbitmq.conf         # RabbitMQ configuration
│   └── php/
│       ├── 8.2/
│       ├── 8.3/
│       └── 8.4/
│           ├── base/
│           │   └── Dockerfile    # Base production image
│           ├── dev/
│           │   └── Dockerfile    # Development image with Xdebug
│           ├── prod/
│           │   └── Dockerfile    # Production build image
│           ├── conf/
│           │   ├── Caddyfile     # Caddy/FrankenPHP configuration
│           │   ├── app.ini       # PHP application settings
│           │   ├── mail.ini      # Mail configuration
│           │   ├── opcache.ini   # OPcache settings
│           │   └── xdebug.ini    # Xdebug configuration
│           ├── entrypoint.sh     # Development entrypoint
│           └── entrypoint-prod.sh # Production entrypoint
├── src/                          # Magento source code (gitignored)
├── docker-compose.yml            # Development compose file
├── docker-compose.prod.yml       # Production compose file
├── CHANGELOG.md                  # Release history
├── CONTRIBUTING.md               # Contribution guidelines
├── Makefile                      # Common commands
└── README.md                     # This file
```

---

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | `localhost` | Domain name |
| `USER_ID` | `1000` | UID for www-data (dev) |
| `GROUP_ID` | `1000` | GID for www-data (dev) |
| `MAGENTO_RUN_MODE` | `developer` | Magento mode |

### PHP Extensions

```
bcmath, gd, intl, mbstring, opcache, pdo_mysql, soap, xsl, zip, sockets, ftp, sodium, redis, apcu
```

### Xdebug (Dev only)

```ini
xdebug.mode = debug
xdebug.client_host = host.docker.internal
xdebug.client_port = 9003
xdebug.start_with_request = trigger
xdebug.idekey = PHPSTORM
```

---

## 🛠️ Commands

### Docker Compose

```bash
# Start
docker compose up -d

# Stop
docker compose down

# Logs
docker compose logs -f app

# Shell
docker compose exec app bash
```

### Magento CLI

```bash
# Run Magento commands
docker compose exec app bin/magento cache:flush
docker compose exec app bin/magento setup:upgrade
docker compose exec app bin/magento indexer:reindex
```

### Build Images

```bash
# Generate Dockerfiles
./bin/generate-dockerfiles.sh

# Build all versions
./bin/build-all.sh build

# Push to Docker Hub
./bin/build-all.sh push

# Full release
DOCKERHUB_TOKEN=xxx ./bin/build-all.sh release
```

---

## 🏭 Production Deployment

### 1. Build production image

```dockerfile
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10-base

COPY --chown=www-data:www-data src/ /var/www/html/

USER www-data
RUN composer install --no-dev --optimize-autoloader
RUN bin/magento setup:di:compile
RUN bin/magento setup:static-content:deploy -f
```

### 2. Deploy

```bash
docker compose -f docker-compose.prod.yml up -d
```

---

## 🔒 Security

The Caddyfile includes:

- ✅ Sensitive files blocked (`.git`, `.env`, `.htaccess`)
- ✅ Directory traversal protection
- ✅ XML files in `/errors/` blocked
- ✅ Customer/downloadable media protected
- ✅ X-Frame-Options headers
- ✅ Automatic HTTPS

---

## 📊 Performance

### vs PHP-FPM + Nginx

| Metric | FrankenPHP | PHP-FPM |
|--------|------------|---------|
| Requests/sec | ~2500 | ~1800 |
| Memory usage | Lower | Higher |
| Cold start | Faster | Slower |
| Config complexity | Simple | Complex |

---

## 🐛 Troubleshooting

### Permission issues

```bash
# Fix permissions
docker compose exec app chown -R www-data:www-data var generated pub
```

### Xdebug not working

```bash
# Check Xdebug is loaded
docker compose exec app php -m | grep xdebug

# Verify config
docker compose exec app php -i | grep xdebug
```

### Container won't start

```bash
# Check logs
docker compose logs app

# Validate Caddyfile
docker compose exec app caddy validate --config /etc/caddy/Caddyfile
```

---

## 📜 Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository 
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## ✉️ Author

**Mohamed El Mrabet**

- GitHub: [@mohelmrabet](https://github.com/mohelmrabet)
- Email: contact@cleatsquad.dev
- Docker Hub: [mohelmrabet](https://hub.docker.com/u/mohelmrabet)

---

## 🔗 Links

- [FrankenPHP](https://frankenphp.dev/)
- [Magento 2](https://magento.com/)
- [Caddy Server](https://caddyserver.com/)
- [Docker Hub](https://hub.docker.com/r/mohelmrabet/magento-frankenphp)