# Magento 2 Docker + FrankenPHP

> Production-ready Docker environment for Magento 2 with FrankenPHP — the modern, high-performance PHP application server

<p align="center">
  <img src="https://frankenphp.dev/img/logo_darkbg.svg" width="150" alt="FrankenPHP Logo" />
</p>

<p align="center">
  <a href="https://hub.docker.com/r/mohelmrabet/magento-frankenphp"><img src="https://img.shields.io/docker/pulls/mohelmrabet/magento-frankenphp.svg?logo=docker" alt="Docker Pulls" /></a>
  <img src="https://img.shields.io/badge/magento-2.4.x-orange.svg?logo=magento" alt="Magento 2.4.x" />
  <img src="https://img.shields.io/badge/php-8.2%20|%208.3%20|%208.4-blue.svg?logo=php" alt="PHP Versions" />
  <img src="https://img.shields.io/badge/frankenphp-1.10-purple.svg" alt="FrankenPHP 1.10" />
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License MIT" /></a>
  <img src="https://img.shields.io/badge/version-v1.0.0-brightgreen.svg" alt="Version 1.0.0" />
</p>

## About This Template

This repository is a **GitHub template** providing a ready-to-use Docker development and production environment for Magento 2 with FrankenPHP. Use it to bootstrap new Magento projects quickly with best practices for containerization.

### Key Features

- **FrankenPHP** — Modern PHP application server with Caddy
- **Automatic HTTPS** — Built-in SSL via Caddy
- **Full Docker Stack** — MariaDB, OpenSearch, Valkey, RabbitMQ, Mailhog
- **High Performance** — OPcache optimized, ~2500 req/s
- **Dev Tools** — Xdebug, CLI scripts, hot-reload ready

## Links

- [Docker Hub](https://hub.docker.com/r/mohelmrabet/magento-frankenphp)
- [Docker Images Repository](https://github.com/CleatSquad/magento-frankenphp-images)
- [FrankenPHP](https://frankenphp.dev/)
- [Magento 2](https://business.adobe.com/products/magento/magento-commerce.html)
- [Security Policy](SECURITY.md)

---
## Quick Start

### Use as Template (Recommended)

1. Click **"Use this template"** on GitHub to create your own repository
2. Clone your new repository:

```bash
git clone https://github.com/YOUR_USERNAME/your-magento-project.git
cd your-magento-project
```

### Clone Directly

```bash
# 1. Clone
git clone https://github.com/CleatSquad/magento-frankenphp-template.git
cd magento-frankenphp-template

# 2. Setup environment (copies env templates automatically)
./bin/setup

# 3. Start containers
./bin/start

# 4. Access https://magento.localhost
```

### 📁 Project Structure

> **Important:** Place your Magento 2 source code in the `src/` directory.

```
magento-frankenphp-template/
├── src/                    # 👈 Your Magento 2 code goes here
├── bin/                    # CLI tools
├── docker/                 # Docker configurations
├── docs/                   # Documentation
└── env/                    # Environment templates
```

#### Option A: Existing Magento Project

If you already have a Magento project, copy or clone it into the `src/` directory:

```bash
# Copy existing project
cp -r /path/to/your/magento/* src/

# Or clone directly
git clone https://github.com/your-org/your-magento-repo.git src/
```

#### Option B: New Magento Installation

For a fresh Magento installation:

```bash
# 1. Start the containers
./bin/start

# 2. Enter the container and create Magento project
./bin/bash
composer create-project --repository-url=https://repo.magento.com/ \
    magento/project-community-edition .
exit

# 3. Run the interactive setup
./bin/setup-magento
```

The `setup-magento` script will guide you through the installation process, asking for admin credentials, language, currency, and timezone settings.

### Quick Commands

```bash
make init        # Initialize and start (first time)
make up          # Start containers
make down        # Stop containers
make help        # Show all available commands
```

## Features

- **PHP 8.2, 8.3, 8.4** — All Magento-required extensions included
- **Automatic HTTPS** — Via Caddy web server
- **OPcache optimized** — Pre-configured for best performance
- **Composer 2** — Latest version included
- **Xdebug ready** — Pre-configured in dev images
- **Full stack included** — MariaDB, OpenSearch, Valkey, RabbitMQ, Mailhog
- **CLI tools** — Convenient scripts in `bin/` directory

## Documentation

| Guide                                                  | Description |
|--------------------------------------------------------|-------------|
| [Getting Started](docs/getting-started.md)             | Installation and initial setup |
| [CLI Tools](docs/cli.md)                               | All available commands |
| [Configuration](docs/configuration.md)                 | Environment variables and settings |
| [Caddyfile](docs/caddyfile.md)                         | Web server configuration |
| [Xdebug](docs/xdebug.md)                               | Debugging with Xdebug |
| [Production](docs/examples/production-dockerfile.md)   | Production deployment |
| [Local Dev](docs/examples/local-development.md)        | Development environment setup |
| [Kubernetes](docs/examples/kubernetes-deployment.md)   | K8s deployment guide |

## Common Commands

```bash
./bin/start              # Start containers
make up                  # Start containers
./bin/stop               # Stop containers
./bin/magento cache:flush
./bin/bash               # Access app container shell
./bin/setup              # Initial setup
./bin/composer install
./bin/mysql              # Database CLI
make help                # Show all Makefile targets
```

See [CLI Documentation](docs/cli.md) for all commands.

## Requirements

- Docker >= 24.0
- Docker Compose >= 2.20
- Git

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community standards.

## Security

See [SECURITY.md](SECURITY.md) for security policy and best practices.

## License

MIT — see [LICENSE](LICENSE.txt)
