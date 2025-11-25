# Changelog
All notable changes to this project will be documented in this file.

The format is based on **Keep a Changelog**,  
and this project adheres to **Semantic Versioning**.

---

## [Unreleased]
### Added
- FrankenPHP + PHP 8.4 base image preparation
- Development and production Dockerfiles
- Modular Docker environment (MariaDB, OpenSearch, Redis/Valkey, RabbitMQ, Mailhog)
- FrankenPHP Caddy configuration
- Magento-ready PHP extensions
- Entry points for dev and prod
- Environment variable presets and `env/` examples
- Documentation (README)

### Changed
- Improved Dockerfile structure (multi-stage, USER switching, file ownership)
- Enhanced compatibility with Magento 2.4.x
- Improved directory permissions management

### Fixed
- Fix build-context issues with `src/`
- Fix OpenSearch duplicate plugin setting
- Fix Valkey container naming
- Fix `www-data` permissions during Magento compilation

---

## [1.0.0] – 2025-02-01
### Added
- First stable release of the Magento Docker FrankenPHP setup
- Base image published: `mohelmrabet/magento-frankenphp-base:php8.4-fp1.10`
- Production-ready Dockerfile including:
    - `composer install`
- Development Dockerfile including:
    - Xdebug
    - mkcert HTTPS support
    - app user management
- Sample docker-compose.dev and docker-compose.prod files

---

## [0.1.0] – 2025-01-20
### Added
- Initial project structure
- First working prototype with FrankenPHP and Magento
- Early Dockerfile testing
