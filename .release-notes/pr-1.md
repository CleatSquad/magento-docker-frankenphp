### Added

- Docker Compose healthchecks for all services (MariaDB, OpenSearch, Valkey, RabbitMQ, Traefik, app)
- Docker Compose profiles (`dev`, `debug`) for service separation
- Service dependencies with `condition: service_healthy`
- Release automation workflow (`release.yml`) - creates GitHub releases on tag push
- Release drafter configuration for auto-generated release notes
- SECURITY.md with security policy and documentation links
- Bot commands: `@bot generate-release-note`, `@bot smoke-test`
- PR-based changelog workflow - automatically updates CHANGELOG.md on PR merge
- GitHub issue and PR templates

### Changed

- Updated README.md with correct repository URLs
- Simplified documentation (removed icons, lowercase filenames)
- Bin scripts now use `--profile dev` by default
- Consolidated Dockerfile RUN instructions for better caching

### Fixed

- Fixed docker-compose paths after folder reorganization (`./docker/images/`)
- Fixed hadolint warnings (DL3059, SC2086)
