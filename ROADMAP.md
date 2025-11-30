# Roadmap

This document outlines the planned improvements and features for the Magento 2 + FrankenPHP Docker Template.

## Short-term (Implemented ✅)

### 1. Automate Releases with GitHub Actions ✅
- Created `.github/workflows/release.yml` workflow that automatically creates releases when tags are pushed
- Uses `softprops/action-gh-release` for release creation

### 2. Add Release Drafter ✅
- Configured [Release Drafter](https://github.com/release-drafter/release-drafter) to auto-generate release notes from PR labels
- Added `.github/release-drafter.yml` configuration with categories for features, bugs, docs, etc.

### 3. Implement Conventional Commits ✅
- Adopted [Conventional Commits](https://www.conventionalcommits.org/) specification
- Added `.commitlintrc.yml` configuration
- Added `.github/workflows/commitlint.yml` to enforce commit message format

### 4. Add Health Checks ✅
- Added container health check configurations for all services
- Documented health check endpoints in docker-compose files

## Medium-term (Planned)

### 5. Add Semantic Release
- Implement [semantic-release](https://github.com/semantic-release/semantic-release) for fully automated versioning and releases
- Automatically generate CHANGELOG entries

### 6. Docker Image Version Tags
- Tag Docker images with the release version (e.g., `mohelmrabet/magento-frankenphp:v0.2.0`)
- Automate image builds on tag push
- Status: Partially implemented in release workflow

## Long-term (Future)

### 7. Multi-architecture Images
- Build and publish ARM64 images for Apple Silicon support
- Use Docker buildx for multi-platform builds
- Status: Infrastructure ready in release workflow

### 8. Security Scanning
- Add Trivy or similar container scanning in CI
- Publish security advisories for vulnerabilities
- Automate CVE reporting

### 9. Version Compatibility Matrix
- Maintain a compatibility matrix for Magento, PHP, and FrankenPHP versions
- Document upgrade paths between versions
- Create automated compatibility testing

## Additional Ideas

### 10. Performance Benchmarking
- Add automated performance benchmarks
- Compare FrankenPHP vs traditional PHP-FPM setups
- Publish benchmark results with each release

### 11. Development Environment Improvements
- Add VS Code devcontainer support
- Add GitHub Codespaces configuration
- Pre-configured debugging profiles

### 12. Testing Infrastructure
- Add integration tests for the Docker setup
- Test Magento installation process
- Validate all PHP extensions work correctly

### 13. Documentation Improvements
- Add video tutorials
- Create troubleshooting guide
- Add FAQ section

## Contributing

Want to help implement any of these features? Check out our [Contributing Guide](CONTRIBUTING.md) and feel free to open an issue or PR!

## Version History

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.
