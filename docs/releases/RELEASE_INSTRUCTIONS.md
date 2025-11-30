# Release Management Instructions

This document contains all the commands and release notes needed to publish releases v0.1.0 and v0.2.0.

---

## Section 1: CHANGELOG.md

The CHANGELOG.md file has been created at the root of the repository. See [CHANGELOG.md](../../CHANGELOG.md).

---

## Section 2: Git Tagging Commands

Execute these commands to create and push the annotated tags.

> **Note:** Replace the commit hashes below with the actual commit SHAs from your repository if they differ.

```bash
# Create annotated tag for v0.1.0 (Initial Release)
git tag -a v0.1.0 924cc179eae71a31e7e0fcb7bfc32308f0494f23 -m "v0.1.0 - Initial Release

Initial release of Magento 2 + FrankenPHP Docker template.

Features:
- PHP 8.2, 8.3, 8.4 support
- FrankenPHP 1.10 integration
- Automatic HTTPS via Caddy
- Full development stack (MariaDB, OpenSearch, Valkey, RabbitMQ, Mailhog)
- Convenient CLI tools
- Docker images on Docker Hub"

# Create annotated tag for v0.2.0 (Infrastructure & Template Improvements)
git tag -a v0.2.0 0d769f9fadcc88a6b6aea7dffb3c8e1deabcd260 -m "v0.2.0 - Infrastructure & Template Improvements

Improvements to infrastructure and templates.

Changes:
- Production-ready docker-compose configuration
- Kubernetes deployment examples
- Enhanced documentation
- Docker build fixes and optimizations"

# Push both tags to remote
git push origin v0.1.0 v0.2.0

# Alternative: Push all tags
git push origin --tags
```

---

## Section 3: GitHub Release Notes

### Release v0.1.0 - Initial Release

**Title:** v0.1.0 - Initial Release

**Release Notes:**

```markdown
# 🎉 Magento 2 + FrankenPHP Docker Template - Initial Release

We're excited to announce the first release of the Magento 2 + FrankenPHP Docker template!

## ✨ Highlights

- **FrankenPHP Integration** — Modern, high-performance PHP application server
- **Multi-PHP Support** — Compatible with PHP 8.2, 8.3, and 8.4
- **Automatic HTTPS** — Built-in TLS via Caddy web server
- **Production Ready** — Optimized OPcache settings out of the box

## 🐳 Docker Images

Available on Docker Hub: `mohelmrabet/magento-frankenphp`

| Tag | PHP | Use Case |
|-----|-----|----------|
| `latest` | 8.4 | Production |
| `dev` | 8.4 | Development (with Xdebug) |
| `php8.3-fp1.10.1-base` | 8.3 | Production |
| `php8.2-fp1.10.1-base` | 8.2 | Production |

## 📦 Full Stack Included

- **Database:** MariaDB
- **Search:** OpenSearch
- **Cache:** Valkey
- **Queue:** RabbitMQ
- **Email:** Mailhog

## 🚀 Quick Start

```bash
git clone https://github.com/CleatSquad/magento-frankenphp-template.git
cd magento-frankenphp-template
./bin/setup
./bin/start
```

Access your store at `https://magento.localhost`

## 📖 Documentation

- [Getting Started](docs/getting-started.md)
- [CLI Tools](docs/CLI.md)
- [Configuration](docs/configuration.md)

---

**Full Changelog:** https://github.com/CleatSquad/magento-frankenphp-template/commits/v0.1.0
```

---

### Release v0.2.0 - Infrastructure & Template Improvements

**Title:** v0.2.0 - Infrastructure & Template Improvements

**Release Notes:**

```markdown
# 🚀 Magento 2 + FrankenPHP Docker Template v0.2.0

This release brings infrastructure improvements and enhanced documentation.

## ✨ What's New

### 📦 Production Configuration
- New `docker-compose.prod.yml` for production deployments
- Production Dockerfile examples

### ☸️ Kubernetes Support
- Kubernetes deployment guide and examples
- Production-ready manifests

### 📖 Enhanced Documentation
- Comprehensive CLI documentation
- Xdebug configuration guide
- Caddyfile customization guide
- Local development setup guide

### 🔧 Bug Fixes
- Fixed Docker build reliability issues
- Improved environment variable handling

## 📥 Upgrade Guide

If upgrading from v0.1.0:

1. Pull the latest changes:
   ```bash
   git pull origin main
   ```

2. Rebuild containers:
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

## 📖 Documentation

- [Getting Started](docs/getting-started.md)
- [Production Deployment](examples/production-dockerfile.md)
- [Kubernetes Guide](examples/kubernetes-deployment.md)
- [Xdebug Setup](docs/xdebug.md)

---

**Full Changelog:** https://github.com/CleatSquad/magento-frankenphp-template/compare/v0.1.0...v0.2.0
```

---

## Section 4: Recommended Improvements

### Short-term Recommendations

1. **Automate Releases with GitHub Actions**
   - Create a `.github/workflows/release.yml` workflow that automatically creates releases when tags are pushed
   - Use `actions/create-release` or similar action

2. **Add Release Drafter**
   - Configure [Release Drafter](https://github.com/release-drafter/release-drafter) to auto-generate release notes from PR labels
   - Add `.github/release-drafter.yml` configuration

3. **Implement Conventional Commits**
   - Adopt [Conventional Commits](https://www.conventionalcommits.org/) specification
   - Use tools like `commitlint` to enforce commit message format

### Medium-term Recommendations

4. **Add Semantic Release**
   - Implement [semantic-release](https://github.com/semantic-release/semantic-release) for fully automated versioning and releases
   - Automatically generate CHANGELOG entries

5. **Docker Image Version Tags**
   - Tag Docker images with the release version (e.g., `mohelmrabet/magento-frankenphp:v0.2.0`)
   - Automate image builds on tag push

6. **Add Health Checks**
   - Document health check endpoints
   - Add container health check configurations

### Long-term Recommendations

7. **Multi-architecture Images**
   - Build and publish ARM64 images for Apple Silicon support
   - Use Docker buildx for multi-platform builds

8. **Security Scanning**
   - Add Trivy or similar container scanning in CI
   - Publish security advisories for vulnerabilities

9. **Version Compatibility Matrix**
   - Maintain a compatibility matrix for Magento, PHP, and FrankenPHP versions
   - Document upgrade paths between versions
