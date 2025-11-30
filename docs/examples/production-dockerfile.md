# Example: Custom Production Dockerfile

This example shows how to create a production-ready Magento Docker image using the FrankenPHP base image.

## Quick Start

A ready-to-use production Dockerfile is provided at `images/Dockerfile.prod`:

```bash
# Build the production image
docker build -f images/Dockerfile.prod -t my-magento-store:latest .

# Run the container
docker run -d \
  --name magento-prod \
  -p 80:80 \
  -p 443:443 \
  -e SERVER_NAME=mystore.example.com \
  my-magento-store:latest
```

Or use docker-compose by uncommenting the build section in `docker-compose.prod.yml`:

```yaml
services:
  app:
    # Option 1: Use pre-built image (default)
    # image: mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-base
    # Option 2: Build production image with compiled DI and static content
    build:
      context: .
      dockerfile: images/Dockerfile.prod
```

## images/Dockerfile.prod

A ready-to-use production Dockerfile is provided at `images/app/Dockerfile`:

```bash
# Build the production image
docker build -f images/app/Dockerfile -t my-magento-store:latest src/

# Run the container
docker run -d \
  --name magento-prod \
  -p 80:80 \
  -p 443:443 \
  -e SERVER_NAME=mystore.example.com \
  my-magento-store:latest
```

Or use docker-compose by uncommenting the build section in `docker-compose.prod.yml`:

```yaml
services:
  app:
    # Option 1: Use pre-built image (default)
    # image: mohelmrabet/magento-frankenphp:php8.4-fp1.10.1-base
    # Option 2: Build production image with compiled DI and static content
    build:
      context: .
      dockerfile: images/app/Dockerfile
```

## Build Pipeline (Recommended)

Use the build script for automated production builds (inspired by ECE-Tools):

```bash
# 1. Create your build configuration (copy from template)
cp docker/conf/build.yaml.example build.yaml

# PHP configuration is already optimized in the base image
# You can override by mounting custom config files if needed

# 3. Run the build script
./bin/build-prod -t my-magento-store:latest

# 4. Push to registry (optional)
./bin/build-prod -t ghcr.io/myorg/magento:v1.0 --push
```

### Build Script Options

```bash
./bin/build-prod [OPTIONS]

Options:
  -c, --config FILE     Path to build.yaml config file (default: build.yaml)
  -t, --tag TAG         Docker image tag (default: magento-prod:latest)
  -f, --dockerfile FILE Path to Dockerfile (default: images/app/Dockerfile)
  --context PATH        Docker build context (default: current directory)
  --push                Push image to registry after build
  --no-cache            Build without Docker cache
  -h, --help            Show help message
```

### CI/CD Pipeline (GitHub Actions)

Copy `examples/build-prod-workflow.yaml` to `.github/workflows/` for automated builds:

```yaml
# Trigger manually or on release
name: Build Production Image

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: 'Docker image tag'
        default: 'latest'
  release:
    types: [published]
```

See `examples/build-prod-workflow.yaml` for full GitHub Actions workflow.

### Other CI/CD Platforms

For Azure DevOps, GitLab CI, Jenkins, and other platforms, see **[CI/CD Pipeline Examples](./ci-cd-pipelines.md)** for complete pipeline examples.

## Static Content Deployment Configuration

### Option 1: Build Configuration File (ECE-Tools Style)

Create `build.yaml` in your project root:

```yaml
build:
  SCD_STRATEGY: "compact"
  SCD_THREADS: 5
  SCD_MATRIX:
    "Vendor/Theme1":
      language:
        - en_US
        - fr_FR
        - de_DE
    "Vendor/Theme2":
      language:
        - en_US
        - fr_FR
    "Magento/backend":
      language:
        - en_US
        - fr_FR
```

Then run: `./bin/build-prod`

### Option 2: Build Arguments (Manual)

Configure themes and languages via build arguments:

```bash
# Build the production image
docker build -f images/Dockerfile.prod -t my-magento-store:latest .

Available build arguments:
- `STATIC_CONTENT_THEMES` - Space-separated list of frontend themes (default: "Magento/blank Magento/luma")
- `STATIC_CONTENT_ADMINHTML_THEME` - Admin theme (default: "Magento/backend")
- `STATIC_CONTENT_LANGUAGES` - Space-separated list of locales (default: "en_US")
- `SCD_THREADS` - Number of parallel threads (default: 5)
- `SCD_STRATEGY` - Deployment strategy: compact, quick, standard (default: "compact")

For a reference configuration file inspired by Adobe ECE-Tools, see `docker/conf/build.yaml.example`.

## Kubernetes Deployment

After building your image, deploy to Kubernetes:

```bash
# Build and push to registry
./bin/build-prod -t ghcr.io/myorg/magento:v1.0 --push

# Deploy to Kubernetes
kubectl apply -f kubernetes/deployment.yaml
```

See `examples/kubernetes-deployment.md` for Kubernetes manifests.

## Docker Compose Production

```yaml
# docker-compose.prod.yml
services:
  app:
    image: ghcr.io/myorg/magento:v1.0  # Use your built image
    ports:
      - "80:80"
      - "443:443"
    environment:
      - SERVER_NAME=mystore.example.com
      - MAGENTO_RUN_MODE=production
```

## Multi-stage Build (Reference)

The `images/app/Dockerfile` already uses a multi-stage build. Here's the pattern:

```dockerfile
# Stage 1: Build
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10-dev AS builder

WORKDIR /var/www/html
COPY --chown=www-data:www-data . .

USER www-data
RUN composer install --no-dev --optimize-autoloader
RUN php -d memory_limit=4G bin/magento setup:di:compile
RUN php -d memory_limit=4G bin/magento setup:static-content:deploy -f --jobs=16

# Stage 2: Production
FROM mohelmrabet/magento-frankenphp:php8.4-fp1.10-base

WORKDIR /var/www/html
COPY --from=builder --chown=www-data:www-data /var/www/html .

ENV MAGENTO_RUN_MODE=production

USER www-data
ENTRYPOINT ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
```
