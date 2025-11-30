# CI/CD Pipeline Examples

This document provides examples for integrating Magento Docker builds into various CI/CD platforms.

## Table of Contents

- [Build Script (bin/build-prod)](#build-script-binbuild-prod)
- [Azure DevOps](#azure-devops)
- [GitHub Actions](#github-actions)
- [GitLab CI](#gitlab-ci)
- [Jenkins](#jenkins)
- [Generic Shell Script](#generic-shell-script)

---

## Build Script (bin/build-prod)

The `bin/build-prod` script is a command-line tool for building production-ready Magento Docker images. It parses `build.yaml` configuration files and passes the appropriate build arguments to Docker.

### Installation

The script is included in the `magento-docker-frankenphp` repository. Copy it to your Magento project:

```bash
# From magento-docker-frankenphp repository
cp bin/build-prod /path/to/your/magento/bin/
chmod +x /path/to/your/magento/bin/build-prod
```

### Usage

```bash
./bin/build-prod [OPTIONS]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-c, --config FILE` | Path to build.yaml config file | `build.yaml` |
| `-t, --tag TAG` | Docker image tag | `magento-prod:latest` |
| `-f, --dockerfile FILE` | Path to Dockerfile | `docker/images/app/Dockerfile` |
| `--context PATH` | Docker build context | `.` (current directory) |
| `--push` | Push image to registry after build | - |
| `--no-cache` | Build without Docker cache | - |
| `-h, --help` | Show help message | - |

### Examples

```bash
# Basic build with defaults
./bin/build-prod

# Build with custom tag
./bin/build-prod -t myregistry/magento:v1.0

# Build with custom config file
./bin/build-prod -c my-build.yaml -t myregistry/magento:v1.0

# Build and push to registry
./bin/build-prod -t ghcr.io/myorg/magento:latest --push

# Build without cache (fresh build)
./bin/build-prod -t magento:latest --no-cache
```

### Configuration File (build.yaml)

Create a `build.yaml` file in your project root to configure static content deployment:

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

### Environment Variable Overrides

You can override config values with environment variables:

```bash
export SCD_STRATEGY_OVERRIDE="quick"
export SCD_THREADS_OVERRIDE="8"
export STATIC_CONTENT_THEMES_OVERRIDE="Vendor/MyTheme"
export STATIC_CONTENT_LANGUAGES_OVERRIDE="en_US fr_FR de_DE"

./bin/build-prod -t myregistry/magento:latest
```

---

## Azure DevOps

### Azure Pipeline (azure-pipelines.yml)

Create `azure-pipelines.yml` in your repository root:

```yaml
trigger:
  branches:
    include:
      - main
      - release/*
  tags:
    include:
      - v*

pool:
  vmImage: 'ubuntu-latest'

variables:
  # Container Registry
  containerRegistry: 'your-acr-name.azurecr.io'
  imageRepository: 'magento'
  dockerfilePath: 'docker/images/app/Dockerfile'
  
  # Build Configuration
  STATIC_CONTENT_THEMES: 'Magento/blank Magento/luma'
  STATIC_CONTENT_LANGUAGES: 'en_US'
  SCD_THREADS: '5'
  SCD_STRATEGY: 'compact'
  BASE_URL: 'https://$(Build.Repository.Name).azurewebsites.net/'

stages:
  - stage: Build
    displayName: 'Build and Push Image'
    jobs:
      - job: BuildImage
        displayName: 'Build Magento Production Image'
        steps:
          - task: Docker@2
            displayName: 'Login to ACR'
            inputs:
              containerRegistry: 'AzureContainerRegistry'
              command: 'login'

          - task: Docker@2
            displayName: 'Build Image'
            inputs:
              containerRegistry: 'AzureContainerRegistry'
              repository: '$(imageRepository)'
              command: 'build'
              Dockerfile: '$(dockerfilePath)'
              buildContext: '.'
              arguments: |
                --build-arg STATIC_CONTENT_THEMES="$(STATIC_CONTENT_THEMES)"
                --build-arg STATIC_CONTENT_LANGUAGES="$(STATIC_CONTENT_LANGUAGES)"
                --build-arg SCD_THREADS=$(SCD_THREADS)
                --build-arg SCD_STRATEGY=$(SCD_STRATEGY)
                --build-arg BASE_URL="$(BASE_URL)"
              tags: |
                $(Build.BuildId)
                latest

          - task: Docker@2
            displayName: 'Push Image'
            inputs:
              containerRegistry: 'AzureContainerRegistry'
              repository: '$(imageRepository)'
              command: 'push'
              tags: |
                $(Build.BuildId)
                latest

  - stage: Deploy
    displayName: 'Deploy to AKS'
    dependsOn: Build
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployToAKS
        displayName: 'Deploy to Kubernetes'
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: KubernetesManifest@0
                  displayName: 'Deploy to AKS'
                  inputs:
                    action: 'deploy'
                    kubernetesServiceConnection: 'AKS-Connection'
                    namespace: 'magento'
                    manifests: |
                      $(Pipeline.Workspace)/kubernetes/*.yaml
                    containers: |
                      $(containerRegistry)/$(imageRepository):$(Build.BuildId)
```

### Azure DevOps with Variables Groups

For more flexibility, use Variable Groups in Azure DevOps:

1. Go to **Pipelines > Library > Variable Groups**
2. Create a group named `magento-build-config`
3. Add variables:
   - `STATIC_CONTENT_THEMES`: `Vendor/Theme1 Vendor/Theme2`
   - `STATIC_CONTENT_LANGUAGES`: `en_US fr_FR de_DE`
   - `SCD_THREADS`: `5`
   - `SCD_STRATEGY`: `compact`
   - `BASE_URL`: `https://mystore.com/`

Then reference in pipeline:

```yaml
variables:
  - group: magento-build-config

stages:
  - stage: Build
    jobs:
      - job: BuildImage
        steps:
          - script: |
              docker build \
                --build-arg STATIC_CONTENT_THEMES="$(STATIC_CONTENT_THEMES)" \
                --build-arg STATIC_CONTENT_LANGUAGES="$(STATIC_CONTENT_LANGUAGES)" \
                --build-arg SCD_THREADS=$(SCD_THREADS) \
                --build-arg SCD_STRATEGY=$(SCD_STRATEGY) \
                --build-arg BASE_URL="$(BASE_URL)" \
                -f docker/images/app/Dockerfile \
                -t $(containerRegistry)/magento:$(Build.BuildId) \
                .
            displayName: 'Build Docker Image'
```

---

## GitHub Actions

### Complete Workflow (.github/workflows/build-prod.yml)

```yaml
name: Build Production Image

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      image_tag:
        description: 'Docker image tag'
        required: false
        default: 'latest'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Log in to Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: docker/images/app/Dockerfile
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          build-args: |
            STATIC_CONTENT_THEMES=${{ vars.STATIC_CONTENT_THEMES || 'Magento/blank Magento/luma' }}
            STATIC_CONTENT_LANGUAGES=${{ vars.STATIC_CONTENT_LANGUAGES || 'en_US' }}
            SCD_THREADS=${{ vars.SCD_THREADS || '5' }}
            SCD_STRATEGY=${{ vars.SCD_STRATEGY || 'compact' }}
            BASE_URL=${{ vars.BASE_URL || 'http://localhost/' }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## GitLab CI

### .gitlab-ci.yml

```yaml
stages:
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"
  # Build Configuration
  STATIC_CONTENT_THEMES: "Magento/blank Magento/luma"
  STATIC_CONTENT_LANGUAGES: "en_US"
  SCD_THREADS: "5"
  SCD_STRATEGY: "compact"
  BASE_URL: "https://${CI_PROJECT_NAME}.example.com/"

build:
  stage: build
  image: docker:24.0.5
  services:
    - docker:24.0.5-dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - |
      docker build \
        --build-arg STATIC_CONTENT_THEMES="${STATIC_CONTENT_THEMES}" \
        --build-arg STATIC_CONTENT_LANGUAGES="${STATIC_CONTENT_LANGUAGES}" \
        --build-arg SCD_THREADS=${SCD_THREADS} \
        --build-arg SCD_STRATEGY=${SCD_STRATEGY} \
        --build-arg BASE_URL="${BASE_URL}" \
        -f docker/images/app/Dockerfile \
        -t ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA} \
        -t ${CI_REGISTRY_IMAGE}:latest \
        .
    - docker push ${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}
    - docker push ${CI_REGISTRY_IMAGE}:latest
  only:
    - main
    - tags

deploy_production:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl set image deployment/magento app=${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA} -n magento
  environment:
    name: production
    url: https://mystore.example.com
  only:
    - main
  when: manual
```

---

## Jenkins

### Jenkinsfile

```groovy
pipeline {
    agent any
    
    environment {
        REGISTRY = 'your-registry.com'
        IMAGE_NAME = 'magento'
        STATIC_CONTENT_THEMES = 'Magento/blank Magento/luma'
        STATIC_CONTENT_LANGUAGES = 'en_US'
        SCD_THREADS = '5'
        SCD_STRATEGY = 'compact'
        BASE_URL = 'https://mystore.com/'
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", 'docker-credentials') {
                        def customImage = docker.build(
                            "${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}",
                            """--build-arg STATIC_CONTENT_THEMES="${STATIC_CONTENT_THEMES}" \
                               --build-arg STATIC_CONTENT_LANGUAGES="${STATIC_CONTENT_LANGUAGES}" \
                               --build-arg SCD_THREADS=${SCD_THREADS} \
                               --build-arg SCD_STRATEGY=${SCD_STRATEGY} \
                               --build-arg BASE_URL="${BASE_URL}" \
                               -f docker/images/app/Dockerfile ."""
                        )
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            when {
                branch 'main'
            }
            steps {
                withKubeConfig([credentialsId: 'kube-config']) {
                    sh """
                        kubectl set image deployment/magento \
                            app=${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} \
                            -n magento
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

---

## Generic Shell Script

For any CI/CD system, use the provided `bin/build-prod` script from this repository:

> **Note:** The `bin/build-prod` script is included in the `magento-docker-frankenphp` project. 
> Copy it to your Magento project or reference it from the cloned repository.

### Basic Usage

```bash
#!/bin/bash
set -e

# Configure build
export STATIC_CONTENT_THEMES="Vendor/Theme1 Vendor/Theme2"
export STATIC_CONTENT_LANGUAGES="en_US fr_FR de_DE"
export SCD_THREADS=5
export SCD_STRATEGY="compact"
export BASE_URL="https://mystore.com/"

# Build and push (run from project root)
./bin/build-prod \
    -t myregistry.com/magento:${BUILD_NUMBER:-latest} \
    --push
```

### With build.yaml Configuration

1. Create `build.yaml`:

```yaml
build:
  SCD_STRATEGY: "compact"
  SCD_THREADS: 5
  SCD_MATRIX:
    "Vendor/Theme1":
      language:
        - en_US
        - fr_FR
    "Magento/backend":
      language:
        - en_US
```

2. Run build:

```bash
./bin/build-prod -c build.yaml -t myregistry.com/magento:v1.0 --push
```

---

## Environment Variables Reference

All CI/CD systems can use these build arguments:

| Variable | Description | Default |
|----------|-------------|---------|
| `STATIC_CONTENT_THEMES` | Space-separated frontend themes | `Magento/blank Magento/luma` |
| `STATIC_CONTENT_ADMINHTML_THEME` | Admin theme | `Magento/backend` |
| `STATIC_CONTENT_LANGUAGES` | Space-separated locales | `en_US` |
| `SCD_THREADS` | Parallel deployment threads | `5` |
| `SCD_STRATEGY` | SCD strategy (compact/quick/standard) | `compact` |
| `BASE_URL` | Base URL for static content | `http://localhost/` |

---

## Best Practices

1. **Use Docker layer caching** - Most CI/CD systems support layer caching to speed up builds
2. **Store secrets securely** - Use your CI/CD's secret management for registry credentials
3. **Tag with commit SHA** - Always tag images with the commit SHA for traceability
4. **Use multi-stage builds** - The provided Dockerfile already uses multi-stage builds
5. **Configure resource limits** - Magento builds can be memory-intensive (4GB+ recommended)

---

## Troubleshooting

### Build fails with memory error

Increase Docker memory limit or add `--memory` flag:

```bash
docker build --memory=4g -f docker/images/app/Dockerfile .
```

### Static content deployment fails

Ensure `STATIC_CONTENT_THEMES` matches your installed themes exactly.

### Registry authentication fails

Check that your CI/CD service has proper credentials configured for your container registry.
