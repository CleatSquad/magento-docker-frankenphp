# Changelog

All notable changes to the Magento 2 + FrankenPHP Docker Template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- fix: Update changelog-update.yml to create PR instead of direct push to protected branch

_From PR #74: fix: Update changelog-update.yml to create PR instead of direct push to protected branch_

## [v1.0.0] - 2025-11-30

### Fixed

- Fix @bot generate-release-note command + workflow improvements

_From PR #5: Fix @bot generate-release-note command + workflow improvements_

### Added
- GitHub issue and PR templates (bug report, feature request, pull request)
- `SECURITY.md` with security policy and production best practices
- Docker Compose healthchecks for all services (MariaDB, OpenSearch, Valkey, RabbitMQ, Traefik, app)
- Docker Compose profiles (`dev`, `prod`, `debug`) for service separation
- `depends_on` with `condition: service_healthy` for proper startup order
- GitHub Actions workflow improvements:
  - `docker-compose-validate` job for syntax validation
  - `smoke-test` job for container health verification
- Release automation:
  - `.github/workflows/release.yml` for automated releases on tag push
  - `.github/release-drafter.yml` for auto-generated release notes

### Changed
- Bin scripts (`start`, `stop`, `status`, `logs`, `remove`, `removeall`) now use `--profile dev` by default
- Improved `.gitignore` with proper patterns for Magento inside `src/` directory
- Added `src/.keep` and `docker/conf/ssl/.keep` for empty directory tracking
- Bug report template enhanced with Magento Version field

### Fixed
- `bin/start` now works correctly with Docker Compose profiles

## [v0.2.0] - 2025-11-29

### Added
- Production-ready `docker-compose.prod.yml` configuration
- Kubernetes deployment examples and documentation
- Comprehensive CLI documentation in `docs/CLI.md`
- Xdebug configuration guide in `docs/xdebug.md`
- Caddyfile configuration documentation in `docs/Caddyfile.md`
- Production Dockerfile example in `examples/`
- Local development setup guide

### Changed
- Improved Docker build process for better reliability
- Enhanced environment variable configuration structure
- Updated documentation with clearer examples

### Fixed
- Docker build issues and optimizations

## [v0.1.0] - 2024-04-10

### Added
- Initial release of Magento 2 + FrankenPHP Docker template
- Support for PHP 8.2, 8.3, and 8.4
- FrankenPHP 1.10 integration with automatic HTTPS via Caddy
- Pre-configured OPcache settings for optimal performance
- Composer 2 included in all images
- Full development stack support:
  - MariaDB for database
  - OpenSearch for search functionality
  - Valkey for caching
  - RabbitMQ for message queue
  - Mailhog for email testing
- Convenient CLI tools in `bin/` directory:
  - `bin/setup` - Initial setup script
  - `bin/start` / `bin/stop` - Container management
  - `bin/magento` - Magento CLI wrapper
  - `bin/composer` - Composer wrapper
  - `bin/bash` - Container shell access
  - `bin/mysql` - Database CLI access
- Docker images available on Docker Hub (`mohelmrabet/magento-frankenphp`)
- Development images with Xdebug pre-configured
- Getting Started documentation
- Configuration guide with environment variables
- MIT License

[Unreleased]: https://github.com/CleatSquad/magento-frankenphp-template/compare/v1.0.0...HEAD
[v1.0.0]: https://github.com/CleatSquad/magento-frankenphp-template/compare/v0.2.0...v1.0.0
[v0.2.0]: https://github.com/CleatSquad/magento-frankenphp-template/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/CleatSquad/magento-frankenphp-template/releases/tag/v0.1.0
