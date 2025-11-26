# Changelog
All notable changes to this project will be documented in this file.

This format follows **Keep a Changelog**,  
and this project adheres to **Semantic Versioning**.

---

## [Unreleased]

### Added
- Integrated **mhsendmail** into the development Docker image to support MailHog email interception.
- Automatic configuration of PHP’s `sendmail_path` through a dedicated `zz-mailhog.ini` file in the DEV environment.
- Clear environment separation for email handling:
    - **DEV** → MailHog + mhsendmail (email capture)
    - **PROD** → Native `mail()` disabled via `SENDMAIL_PATH=/dev/null`
- Updated production entrypoint and Dockerfile logic to ensure Magento relies on an SMTP module for real email delivery.
- Expanded documentation describing email behavior across DEV and PROD.
- Various quality-of-life improvements for development and enhanced error visibility.
- Added full support for **PHP 8.3**, including a new FrankenPHP 1.10 base image and build logic.

### Changed
- Updated DEV Dockerfile to enable MailHog routing by default for consistent development email behavior.
- Updated PROD Dockerfile to explicitly disable PHP's native `mail()` function for improved safety and consistency.
- Improved clarity and maintainability of DEV/PROD PHP configuration files.
- Increased consistency in environment variables, PHP INI overrides, and overall configuration structure.

### Fixed
- Missing sendmail wrapper in DEV containers (mhsendmail is now properly installed).
- Fixed email delivery issues in DEV caused by incorrect PHP `sendmail_path` configuration.
- Clarified documentation regarding potential duplicate script execution under FrankenPHP.
- Minor permission issues impacting development workflows have been resolved.

---

## [1.0.0] – 2025-02-01

### Added
- First stable release of the Magento Docker FrankenPHP setup.
- Base image published: `mohelmrabet/magento-frankenphp-base:php8.4-fp1.10`
- Production-ready Dockerfile including optimizations for:
    - `composer install`
    - autoloader generation
- Development Dockerfile including:
    - Xdebug integration
    - mkcert-based HTTPS support
    - development user environment
- Example `docker-compose.dev.yml` and `docker-compose.prod.yml` configurations.

---

## [0.1.0] – 2025-01-20

### Added
- Initial project structure and bootstrap.
- First working prototype integrating FrankenPHP with Magento.
- Early Dockerfile experiments and environment scaffolding.