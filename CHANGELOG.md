# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### 🎉 Initial Release

First stable release of the Magento FrankenPHP Docker Template.

### Stack Versions

| Component | Version | Notes |
|-----------|---------|-------|
| **Magento** | 2.4.7 | Community & Commerce supported |
| **PHP** | 8.2, 8.3, 8.4 | All Magento-required extensions |
| **FrankenPHP** | 1.10.1 | High-performance PHP server |
| **Caddy** | 2.x | Automatic HTTPS |
| **MariaDB** | 11.4 | LTS release |
| **OpenSearch** | 2.14 | Search engine |
| **Valkey** | 8.1.4 | Redis-compatible cache |
| **RabbitMQ** | 4.1 | Message queue |
| **Traefik** | 3.6 | Reverse proxy (dev) |

### Features

#### Docker Environment
- ✅ Production-ready Docker Compose configuration
- ✅ Development configuration with Xdebug support
- ✅ Health checks for all services
- ✅ Docker profiles for dev/prod/debug separation
- ✅ Automatic HTTPS via Caddy

#### CLI Tools (`bin/`)
- ✅ Full suite of management scripts
- ✅ Magento CLI wrapper
- ✅ Composer integration
- ✅ Database management (MySQL CLI, mysqldump)
- ✅ Cache/Redis CLI access
- ✅ File permission management

#### Configuration
- ✅ Environment-based configuration (.env)
- ✅ Separate environment files per service
- ✅ Customizable Caddyfile
- ✅ Traefik reverse proxy support

#### Documentation
- ✅ Comprehensive getting started guide
- ✅ CLI documentation
- ✅ Configuration reference
- ✅ Xdebug setup guide
- ✅ Production deployment examples
- ✅ Kubernetes deployment guide
- ✅ CI/CD pipeline examples

#### Security
- ✅ Security policy (SECURITY.md)
- ✅ Non-root container execution
- ✅ Secrets management best practices
- ✅ Comprehensive .gitignore

### Docker Images

Available on Docker Hub: [mohelmrabet/magento-frankenphp](https://hub.docker.com/r/mohelmrabet/magento-frankenphp)

| Tag | PHP | FrankenPHP | Use Case |
|-----|-----|------------|----------|
| `php8.4-fp1.10.1-base` / `latest` | 8.4 | 1.10.1 | Production |
| `php8.4-fp1.10.1-dev` / `dev` | 8.4 | 1.10.1 | Development |
| `php8.3-fp1.10.1-base` / `base` | 8.3 | 1.10.1 | Production |
| `php8.3-fp1.10.1-dev` | 8.3 | 1.10.1 | Development |
| `php8.2-fp1.10.1-base` | 8.2 | 1.10.1 | Production |
| `php8.2-fp1.10.1-dev` | 8.2 | 1.10.1 | Development |

### Performance

Benchmark results (typical workload):
- **FrankenPHP**: ~2500 requests/second
- **PHP-FPM + Nginx**: ~1800 requests/second

### Requirements

- Docker >= 24.0
- Docker Compose >= 2.20
- Git
- 8GB RAM minimum (recommended for Magento)

### Links

- [Docker Hub](https://hub.docker.com/r/mohelmrabet/magento-frankenphp)
- [Docker Images Repository](https://github.com/CleatSquad/magento-frankenphp-images)
- [FrankenPHP](https://frankenphp.dev/)
- [Magento 2](https://business.adobe.com/products/magento/magento-commerce.html)

---

## [Unreleased]

### Added
- (Future features will be listed here)

### Changed
- (Future changes will be listed here)

### Fixed
- (Future fixes will be listed here)
