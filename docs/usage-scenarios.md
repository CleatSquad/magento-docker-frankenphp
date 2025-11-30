# Usage Scenarios

This guide covers different deployment scenarios for the Magento FrankenPHP Docker template.

## Scenario 1: Local Development

The most common use case for setting up a Magento development environment.

### Setup

```bash
# 1. Clone or use template
git clone https://github.com/mohaelmrabet/magento-frankenphp-template.git
cd magento-frankenphp-template

# 2. Configure environment
cp .env.example .env
./bin/setup

# 3. Start services
./bin/start
# or: docker compose up -d
```

### Features

- 🐛 **Xdebug** enabled and pre-configured
- 📧 **Mailhog** for email testing
- 🗄️ **phpMyAdmin** for database management
- 🔄 **Hot reload** - code changes reflect immediately
- 🌐 **Traefik** for easy multi-site development

### Access Points

| Service | URL |
|---------|-----|
| Magento Store | https://magento.localhost |
| Magento Admin | https://magento.localhost/admin |
| Mailhog | http://mailhog.localhost |
| phpMyAdmin | http://myadmin.localhost |
| RabbitMQ | http://rabbit.localhost |
| Traefik Dashboard | http://traefik.localhost |

### Development Tips

```bash
# Watch logs in real-time
./bin/logs

# Access container shell
./bin/bash

# Run Magento CLI commands
./bin/magento cache:flush
./bin/magento setup:upgrade

# Compile DI and deploy static content
make compile
make deploy
```

---

## Scenario 2: Production Deployment

Deploy Magento to a production server.

### Prerequisites

- Server with Docker and Docker Compose
- Domain name pointing to your server
- SSL certificates (or use Caddy's automatic HTTPS)

### Setup

```bash
# 1. Clone repository
git clone https://github.com/mohaelmrabet/magento-frankenphp-template.git
cd magento-frankenphp-template

# 2. Configure production environment
cp .env.example .env

# Edit .env with production values:
# - SERVER_NAME=yourdomain.com
# - Strong database passwords
# - MAGENTO_RUN_MODE=production
nano .env

# 3. Start production stack
docker compose -f docker-compose.prod.yml up -d
```

### Production Configuration

```bash
# .env for production
PROJECT_NAME=magento-prod
SERVER_NAME=yourdomain.com
MAGENTO_RUN_MODE=production

# Use strong passwords!
DB_PASSWORD=<strong-random-password>
MYSQL_ROOT_PASSWORD=<strong-random-password>
RABBITMQ_DEFAULT_PASS=<strong-random-password>
```

### Production Checklist

- [ ] Strong, unique passwords for all services
- [ ] SSL/TLS properly configured
- [ ] Magento in production mode
- [ ] OPcache enabled (default)
- [ ] Two-Factor Authentication enabled
- [ ] Database not exposed externally
- [ ] Regular backups configured
- [ ] Monitoring and alerting set up

### Deployment Commands

```bash
# Deploy code changes
./bin/magento setup:upgrade
./bin/magento setup:di:compile
./bin/magento setup:static-content:deploy -f
./bin/magento cache:flush

# Or use Makefile
make upgrade-magento
make compile
make deploy
make cache
```

---

## Scenario 3: CI/CD Integration

Use this template in your CI/CD pipeline.

### GitHub Actions Example

```yaml
name: Magento CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup environment
        run: |
          cp .env.example .env
          cp env/magento.env.example env/magento.env
          cp env/mariadb.env.example env/mariadb.env
          cp env/opensearch.env.example env/opensearch.env
          cp env/rabbitmq.env.example env/rabbitmq.env
          cp env/valkey.env.example env/valkey.env
          
      - name: Create network
        run: docker network create proxy || true
        
      - name: Start services
        run: docker compose up -d
        
      - name: Wait for services
        run: |
          sleep 60
          docker compose ps
          
      - name: Run tests
        run: |
          docker compose exec -T app bin/magento dev:tests:run unit
          
      - name: Cleanup
        if: always()
        run: docker compose down -v
```

### GitLab CI Example

```yaml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_DRIVER: overlay2

build:
  stage: build
  script:
    - cp .env.example .env
    - docker compose build

test:
  stage: test
  services:
    - docker:dind
  script:
    - docker compose up -d
    - sleep 60
    - docker compose exec -T app bin/magento dev:tests:run unit
  after_script:
    - docker compose down -v

deploy:
  stage: deploy
  only:
    - main
  script:
    - ssh $DEPLOY_USER@$DEPLOY_HOST "cd /app && git pull && docker compose -f docker-compose.prod.yml up -d"
```

---

## Scenario 4: Multi-Site Development

Develop multiple Magento sites simultaneously.

### Setup Multiple Sites

```yaml
# docker-compose.override.yml
services:
  app:
    environment:
      SERVER_NAME: "site1.localhost site2.localhost site3.localhost"
    labels:
      - traefik.http.routers.site1.rule=Host(`site1.localhost`)
      - traefik.http.routers.site2.rule=Host(`site2.localhost`)
      - traefik.http.routers.site3.rule=Host(`site3.localhost`)
```

### Configure Magento Multi-Site

```bash
# In Magento admin or via CLI
./bin/magento config:set web/unsecure/base_url https://site1.localhost/ --scope=website --scope-code=site1
./bin/magento config:set web/secure/base_url https://site1.localhost/ --scope=website --scope-code=site1
```

---

## Scenario 5: Performance Testing

Set up an environment for load testing.

### Configuration

```yaml
# docker-compose.override.yml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
          
  opensearch:
    environment:
      - OPENSEARCH_JAVA_OPTS=-Xms2g -Xmx2g
```

### Run Load Tests

```bash
# Install k6 for load testing
brew install k6  # macOS
# or: apt install k6  # Ubuntu

# Run load test
k6 run loadtest.js
```

### Sample Load Test Script

```javascript
// loadtest.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 50,
  duration: '5m',
};

export default function() {
  const res = http.get('https://magento.localhost/');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

---

## Scenario 6: Extension Development

Develop Magento 2 extensions using this template.

### Project Structure

```
my-extension/
├── src/
│   └── app/
│       └── code/
│           └── Vendor/
│               └── Module/
│                   ├── registration.php
│                   ├── etc/
│                   │   └── module.xml
│                   └── ...
├── docker-compose.yml
├── .env
└── ...
```

### Development Workflow

```bash
# Mount your extension code
# docker-compose.override.yml
services:
  app:
    volumes:
      - ./src:/var/www/html
      - ../my-extension/src:/var/www/html/app/code/Vendor/Module

# Enable extension
./bin/magento module:enable Vendor_Module
./bin/magento setup:upgrade
./bin/magento cache:flush

# Run unit tests
./bin/magento dev:tests:run unit
```

---

## Scenario 7: Database Migration/Import

Import an existing Magento database.

### Import Database

```bash
# 1. Copy SQL dump to project
cp /path/to/database.sql ./dumps/

# 2. Import into MariaDB
./bin/mysql < dumps/database.sql

# Or using Docker directly
docker compose exec -T mariadb mysql -u magento -pmagento magento < dumps/database.sql

# 3. Update base URLs
./bin/magento config:set web/unsecure/base_url https://magento.localhost/
./bin/magento config:set web/secure/base_url https://magento.localhost/

# 4. Clear cache and reindex
./bin/magento cache:flush
./bin/magento indexer:reindex
```

### Export Database

```bash
# Create backup
./bin/mysqldump > dumps/backup-$(date +%Y%m%d).sql

# Compressed backup
./bin/mysqldump | gzip > dumps/backup-$(date +%Y%m%d).sql.gz
```

---

## Environment Profiles

Use Docker Compose profiles to start specific service combinations:

```bash
# Development (all services including debug tools)
docker compose --profile dev up -d

# Production (core services only)
docker compose --profile prod -f docker-compose.prod.yml up -d

# Debug mode (includes additional debugging tools)
docker compose --profile debug up -d
```

## See Also

- [Architecture Overview](architecture.md)
- [Configuration Guide](configuration.md)
- [Customization Guide](customization.md)
- [CLI Tools](CLI.md)
