# Magento Docker Environment (FrankenPHP)

This repository provides a complete Docker-based environment for running Magento 2 using **FrankenPHP**, MariaDB, OpenSearch, Valkey, RabbitMQ, Mailhog, and other optional services.  
It supports both **development** and **production** setups, based on a modular architecture.

---

## 🔧 Prerequisites

Before getting started, ensure you have:

- **Docker**
- **Docker Compose**
- **Git** (optional, if you clone this repository)

---

## 🐳 Docker Hub Images

This project provides a reusable base image for Magento + FrankenPHP:

### **Base Image**
- **mohelmrabet/magento-frankenphp-base:php8.4-fp1.10**  
  https://hub.docker.com/repository/docker/mohelmrabet/magento-frankenphp-base

This image includes:

- PHP 8.4
- FrankenPHP 1.10
- All required Magento extensions
- Composer 2
- System dependencies
- Ready to use for Magento, Laravel, Symfony or custom PHP apps

---

## 📦 Containers Included

### **FrankenPHP (App Server)**
Serves Magento using FrankenPHP, with support for static assets, PHP execution and Caddy configuration.

### **MariaDB**
Magento's primary database (optimized for local and production usage).

### **OpenSearch**
Search engine used by Magento 2.4.x for catalog and Elasticsearch APIs.

### **Valkey**
Used for:
- Cache backend
- Full page cache
- Session storage

### **RabbitMQ** (optional)
Used for Magento message queue and asynchronous tasks.

### **Mailhog** (dev only)
Captures outgoing emails for testing.

---

## 📁 Project Structure

```
.
├── docker-compose.yml             → Development stack
├── docker-compose.prod.yml        → Production stack
├── images/
│   ├── php/8.4/
│   │   ├── Dockerfile.base        → Base image (FrankenPHP + PHP extensions)
│   │   ├── Dockerfile             → Production image (with Magento build)
│   │   ├── Dockerfile.dev         → Development image
│   │   ├── conf/
│   │   │   ├── Caddyfile
│   │   │   ├── app.ini
│   │   │   └── app-prod.ini
│   │   ├── entrypoint.sh
│   │   └── entrypoint-prod.sh
├── src/                           → Your Magento project source code
└── ...
```

---

## ⚙️ Customization

You may customize:

- **Dockerfiles** under `images/php/8.4/`
- **Service definitions** in `docker-compose.yml` and `docker-compose.prod.yml`
- **Caddy configuration** under `images/php/8.4/conf/`
- **Environment variables** in the `env/` folder

This setup is modular, meaning you can enable or disable services as needed.

---

## 🛠️ Troubleshooting

### Permissions issues
If you encounter errors such as:
```
var/ or pub/static not writable
```
Ensure the web server user (`www-data` or `app`) has correct ownership:

```bash
sudo chown -R $USER:$USER src/
```

Or inside the container:

```bash
chmod -R 775 var generated pub/static pub/media
```

### Magento installation errors
Check your installation command:
- Database credentials
- Base URL
- Search engine host (`opensearch`)
- Cache & session configuration

You can test database connectivity:

```bash
docker exec -it magento-db mysql -u magento -pmagento
```

---

## 📄 License

This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute it without restrictions.

---

## ✉️ Author

**Mohamed El Mrabet**  
https://github.com/mohelmrabet  
contact@cleatsquad.dev