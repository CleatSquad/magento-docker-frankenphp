# Magento 2 + FrankenPHP --- Complete Docker Environment (MariaDB + OpenSearch + Valkey)

This repository provides a complete Docker environment for running
**Magento 2 on FrankenPHP**, including MariaDB, OpenSearch, Valkey,
Mailhog, and optional RabbitMQ support.\
It is designed to help developers experiment with **FrankenPHP worker
mode**, compare performance with traditional PHP-FPM, and deploy a fully
reproducible environment suitable for both development and production.

The stack is modular, easy to launch, and optimized for benchmarking as
well as local development workflows.

## 🔧 Prerequisites

Before getting started, make sure you have:

-   **Docker**
-   **Docker Compose**
-   **Git** (optional, if cloning the repository)

## 🐳 Docker Hub Images

This project includes a reusable base image for Magento + FrankenPHP.

### **Base Image**

-   **mohelmrabet/magento-frankenphp-base:php8.4-fp1.10**
-   **mohelmrabet/magento-frankenphp-base:php8.3-fp1.10**
    -   https://hub.docker.com/repository/docker/mohelmrabet/magento-frankenphp-base

This image provides:

-   PHP 8.4
-   FrankenPHP 1.10
-   All required Magento extensions
-   Composer 2
-   System dependencies
-   Support for Magento, Laravel, Symfony, and custom PHP applications

## 📦 Containers Included

### **FrankenPHP (App Server)**

Runs Magento using FrankenPHP with support for static assets, PHP
execution, and Caddy-based configuration.

### **MariaDB**

Primary database for Magento 2, optimized for development and
production.

### **OpenSearch**

Provides search capabilities for Magento 2.4.x using
Elasticsearch-compatible APIs.

### **Valkey**

Used for: - Cache backend\
- Full Page Cache\
- Session storage

### **RabbitMQ** (optional)

Enables Magento's message queues and asynchronous processing.

### **Mailhog** (development only)

Captures outgoing emails during development.

## 📁 Project Structure

    .
    ├── docker-compose.yml             → Development stack
    ├── docker-compose.prod.yml        → Production stack
    ├── images/
    │   ├── php/8.4/
    │   │   ├── Dockerfile.base
    │   │   ├── Dockerfile
    │   │   ├── Dockerfile.dev
    │   │   ├── conf/
    │   │   │   ├── Caddyfile
    │   │   │   ├── app.ini
    │   │   │   └── app-prod.ini
    │   │   ├── entrypoint.sh
    │   │   └── entrypoint-prod.sh
    ├── src/                           → Magento project source code
    └── ...

## ⚙️ Customization

You can customize:

-   **Dockerfiles** under `images/php/8.4/`
-   **Service definitions** in `docker-compose.yml` and
    `docker-compose.prod.yml`
-   **Caddy configuration** under `images/php/8.4/conf/`
-   **Environment variables** in the `env/` directory

## 🛠️ Troubleshooting

### Permission issues

If you encounter:

    var/ or pub/static not writable

Fix permissions:

Host:

``` bash
sudo chown -R $USER:$USER src/
```

Container:

``` bash
chmod -R 775 var generated pub/static pub/media
```

### Magento installation issues

Verify:

-   DB connection\
-   Base URL\
-   OpenSearch host (`opensearch`)\
-   Cache/session config

Test DB connection:

``` bash
docker exec -it magento-db mysql -u magento -pmagento
```

---

## 📜 Changelog

See [CHANGELOG.md](CHANGELOG.md) for full details.

---


## 🤝 Contributing

Contributions are welcome!  
Please open an issue or PR if you want to improve the project.

---

## 📄 License

Released under the **MIT License**.

## ✉️ Author

**Mohamed El Mrabet**\
https://github.com/mohelmrabet\
contact@cleatsquad.dev