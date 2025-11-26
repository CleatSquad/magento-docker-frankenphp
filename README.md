# Magento 2 + FrankenPHP — Complete Docker Environment
### (MariaDB · OpenSearch · Valkey · Mailhog · Optional RabbitMQ)
# <img src="https://frankenphp.dev/img/logo_darkbg.svg" width="180" />

This repository provides a fully featured Docker environment for running **Magento 2 on FrankenPHP**, including services such as MariaDB, OpenSearch, Valkey, Mailhog, and optional RabbitMQ.

It is designed to help developers:
- experiment with **FrankenPHP worker mode**,
- benchmark performance against PHP-FPM,
- deploy a reproducible and modular environment,
- simplify local development workflows and production setups.

---

## 🏷️ Badges

<img src="https://img.shields.io/badge/magento-2.X-brightgreen.svg?logo=magento" />
<a href="https://hub.docker.com/r/mohelmrabet/magento-frankenphp-base/" target="_blank"><img src="https://img.shields.io/docker/pulls/mohelmrabet/magento-frankenphp-base.svg?label=php%20docker%20pulls" /></a>
<a href="https://github.com/mohelmrabet/magento-docker-frankenphp/graphs/commit-activity" target="_blank"><img src="https://img.shields.io/badge/maintained%3F-yes-brightgreen.svg" /></a>
<img src="https://img.shields.io/badge/apple%20silicon%20support-yes-brightgreen" />
<a href="https://opensource.org/licenses/MIT" target="_blank"><img src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>

---

## 🔧 Prerequisites

Make sure the following tools are installed:

- **Docker**
- **Docker Compose**
- **Git** (optional for cloning)

---

## 🐳 Docker Hub Images

### **Base Image**
https://hub.docker.com/repository/docker/mohelmrabet/magento-frankenphp-base


**mohelmrabet/magento-frankenphp-base:php8.4-fp1.10**  
**mohelmrabet/magento-frankenphp-base:php8.3-fp1.10**


This base image includes:

- PHP 8.4
- FrankenPHP 1.10
- Required Magento extensions
- Composer 2
- Optimized system dependencies
- Compatibility with Magento, Symfony, Laravel and custom PHP apps

---

## 📦 Included Containers

### **FrankenPHP (Application Server)**
Handles PHP execution, static assets, workers, and Caddy-based configuration.

### **MariaDB**
Primary database for Magento 2 with optimized configuration for DEV/PROD.

### **OpenSearch**
Search engine compatible with Elasticsearch APIs (mandatory for Magento 2.4+).

### **Valkey**
Used for:
- Cache backend
- Full Page Cache
- Session storage

### **RabbitMQ (optional)**
Supports Magento message queues and asynchronous processing.

### **Mailhog (development only)**
Captures outgoing emails during development.


## ⚙️ Customization

You can customize:

- **Dockerfiles** inside `images/php/8.4/`
- **Compose services** in `docker-compose.yml` / `docker-compose.prod.yml`
- **Caddy configuration** inside `images/php/8.4/conf/`
- **Environment variables** inside the `env/` folder

---

## 📄 License

Licensed under the **MIT License**.

---


## 📜 Changelog

See [CHANGELOG.md](CHANGELOG.md) for full details.

---


## 🤝 Contributing

Contributions are welcome!  
If you'd like to help improve this project, feel free to:

- Open issues
- Submit pull requests
- Propose improvements or new features
- Report bugs
- Improve documentation

Before contributing, please:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Open a Pull Request

Every contribution — big or small — is appreciated and helps the project grow.

---

## ✉️ Author

**Mohamed El Mrabet**  
GitHub: https://github.com/mohelmrabet  
Email: contact@cleatsquad.dev