# Changelog
All notable changes to this project will be documented in this file.

This format follows **Keep a Changelog**,  
and this project adheres to **Semantic Versioning**.

---

## [Unreleased]

### Added
- Integrated **mhsendmail** into the development Docker image for MailHog email capture.
- Automatic configuration of `sendmail_path` using a dedicated `zz-mailhog.ini` file in the DEV environment.
- Environment separation for email handling:
    - **DEV** → MailHog + mhsendmail
    - **PROD** → sendmail disabled using `SENDMAIL_PATH=/dev/null`
- Updated production entrypoint and Dockerfile logic to ensure Magento relies on an SMTP module for real email delivery.
- Additional documentation explaining email behavior in DEV and PROD.
- Minor improvements to development quality-of-life and error visibility.

### Changed
- Updated DEV Dockerfile to include MailHog routing by default.
- Updated PROD Dockerfile to explicitly disable PHP's native `mail()` function for safety.
- Improved clarity and separation between DEV and PROD PHP configurations.
- Enhanced consistency across environment variables and PHP INI files.

### Fixed
- Missing sendmail binary in DEV containers (mhsendmail now installed).
- Email delivery issues in DEV caused by PHP not using the correct sendmail wrapper.
- Clarified potential duplicate script execution under FrankenPHP (documentation updated).
- Minor permission fixes related to development workflows.

---

## [1.0.0] – 2025-02-01

### Added
- First stable release of the Magento Docker FrankenPHP setup.
- Base image published: `mohelmrabet/magento-frankenphp-base:php8.4-fp1.10`
- Production-ready Dockerfile including optimized:
    - `composer install`
    - autoloader generation
- Development Dockerfile including:
    - Xdebug integration
    - mkcert HTTPS support
    - development user management
- Example `docker-compose.dev.yml` and `docker-compose.prod.yml` files.

---

## [0.1.0] – 2025-01-20

### Added
- Initial project structure.
- First working prototype integrating FrankenPHP and Magento.
- Early Dockerfile experimentation and environment bootstrapping.
