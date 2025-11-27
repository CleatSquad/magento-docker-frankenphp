# Benchmark: FrankenPHP vs Nginx + PHP-FPM

This document describes how to run performance benchmarks comparing **FrankenPHP** (using `mohelmrabet/magento-frankenphp`) with a traditional **Nginx + PHP-FPM** setup (using `markoshust/magento-php` from [docker-magento](https://github.com/markshust/docker-magento)).

## Overview

The benchmark suite includes:

- **FrankenPHP**: Using `mohelmrabet/magento-frankenphp:php8.4-fp1.10-base`
- **PHP-FPM**: Using `markoshust/magento-php:8.3-fpm-4` with Nginx
- Identical PHP test scripts for both setups
- Docker Compose configurations for easy deployment
- Automated benchmark script using Apache Bench
- Comparative result analysis

## Quick Start

```bash
# Run the benchmark with default settings
./bin/benchmark

# Run with custom settings
./bin/benchmark -c 50 -n 5000
```

## Prerequisites

- **Docker** >= 24.0
- **Docker Compose** >= 2.20
- **curl**
- **Apache Bench (ab)** - automatically provided via Docker if not installed

## Benchmark Configuration

### Command Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `-c, --concurrency` | Number of concurrent requests | 10 |
| `-n, --requests` | Total number of requests | 1000 |
| `-w, --warmup` | Number of warmup requests | 100 |
| `-h, --help` | Show help message | - |

### Examples

```bash
# Default benchmark (10 concurrent, 1000 requests)
./bin/benchmark

# High concurrency test
./bin/benchmark -c 100 -n 10000

# Quick test
./bin/benchmark -c 5 -n 100 -w 10

# Production-like load
./bin/benchmark -c 50 -n 5000 -w 500
```

## Test Environment

### Nginx + PHP-FPM Stack

| Component | Image | Description |
|-----------|-------|-------------|
| **Nginx** | `nginx:1.27-alpine` | Lightweight Alpine-based Nginx |
| **PHP-FPM** | `markoshust/magento-php:8.3-fpm-4` | Mark Shust's Magento-optimized PHP-FPM |
| **Port** | 8080 | HTTP endpoint |

> The PHP-FPM image from [markshust/docker-magento](https://github.com/markshust/docker-magento) includes all Magento-required extensions and optimizations.

### FrankenPHP Stack

| Component | Image | Description |
|-----------|-------|-------------|
| **FrankenPHP** | `mohelmrabet/magento-frankenphp:php8.4-fp1.10-base` | Magento-optimized FrankenPHP |
| **Port** | 8081 | HTTP endpoint |

> The FrankenPHP image from [mohelmrabet/magento-docker-frankenphp](https://github.com/mohelmrabet/magento-docker-frankenphp) includes all Magento-required extensions and Caddy server.

## Test Script

The benchmark uses a PHP script (`benchmark/html/index.php`) that performs:

1. **CPU-intensive operations**: Fibonacci calculation (n=30)
2. **Array operations**: Generate and sort 10,000 random numbers
3. **String operations**: 1,000 MD5 hash generations
4. **JSON operations**: Encode/decode 1,000 objects

This simulates real-world PHP workloads similar to what Magento 2 experiences.

## Understanding Results

### Metrics Explained

| Metric | Description | Better |
|--------|-------------|--------|
| Requests/sec | Throughput - requests handled per second | Higher |
| Mean time | Average response time in milliseconds | Lower |
| 50th percentile | Median response time | Lower |
| 95th percentile | 95% of requests completed within this time | Lower |
| 99th percentile | 99% of requests completed within this time | Lower |
| Failed requests | Number of requests that failed | Lower (0) |

### Sample Output

```
═══════════════════════════════════════════════════════════════
  Benchmark: FrankenPHP vs Nginx + PHP-FPM
═══════════════════════════════════════════════════════════════

───────────────────────────────────────────────────────────────
  Benchmark Results
───────────────────────────────────────────────────────────────

Metric                     Nginx+PHP-FPM      FrankenPHP      Difference
─────────────────────────────────────────────────────────────────────────
Requests/sec                    1850.23          2456.78        +32.8%
Mean time (ms)                     5.40             4.07        -24.6%
50th percentile (ms)                  5                4        -20.0%
95th percentile (ms)                  8                5        -37.5%
99th percentile (ms)                 12                7        -41.7%
Failed requests                       0                0
```

## Manual Testing

You can also run benchmarks manually:

### 1. Start the services

```bash
cd benchmark

# Start Nginx + PHP-FPM
docker compose -f docker-compose.nginx.yml up -d

# Start FrankenPHP
docker compose -f docker-compose.frankenphp.yml up -d
```

### 2. Verify services are running

```bash
# Test Nginx + PHP-FPM
curl http://localhost:8080/health.php

# Test FrankenPHP
curl http://localhost:8081/health.php
```

### 3. Run Apache Bench manually

```bash
# Benchmark Nginx + PHP-FPM
ab -n 1000 -c 10 http://localhost:8080/index.php

# Benchmark FrankenPHP
ab -n 1000 -c 10 http://localhost:8081/index.php
```

### 4. Stop services

```bash
docker compose -f docker-compose.nginx.yml down
docker compose -f docker-compose.frankenphp.yml down
```

## File Structure

```
benchmark/
├── docker-compose.nginx.yml      # Nginx + PHP-FPM stack
├── docker-compose.frankenphp.yml # FrankenPHP stack
├── nginx-php-fpm/
│   └── conf/
│       ├── nginx.conf            # Nginx main configuration
│       ├── default.conf          # Nginx server block
│       └── php-fpm.conf          # PHP-FPM pool configuration
├── frankenphp/
│   └── Caddyfile                 # FrankenPHP/Caddy configuration
└── html/
    ├── index.php                 # Benchmark test script
    └── health.php                # Health check endpoint
```

## Tuning

### PHP-FPM Configuration

Edit `benchmark/nginx-php-fpm/conf/php-fpm.conf`:

```ini
pm = dynamic
pm.max_children = 50        # Increase for higher concurrency
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 500
```

### Nginx Configuration

Edit `benchmark/nginx-php-fpm/conf/nginx.conf`:

```nginx
worker_processes auto;      # Adjust based on CPU cores
worker_connections 1024;    # Increase for more connections
```

## Expected Results

Based on typical benchmarks:

| Metric | FrankenPHP | Nginx + PHP-FPM |
|--------|------------|-----------------|
| Requests/sec | ~2500 | ~1800 |
| Memory usage | Lower | Higher |
| Cold start | Faster | Slower |
| Config complexity | Simple | Complex |

**Note**: Results vary based on hardware, workload, and configuration.

## Troubleshooting

### Port conflicts

If ports 8080 or 8081 are in use:

```bash
# Check what's using the ports
lsof -i :8080
lsof -i :8081

# Or modify the docker-compose files to use different ports
```

### Services won't start

```bash
# Check container logs
docker compose -f docker-compose.nginx.yml logs
docker compose -f docker-compose.frankenphp.yml logs

# Restart services
docker compose -f docker-compose.nginx.yml restart
docker compose -f docker-compose.frankenphp.yml restart
```

### Apache Bench not found

The benchmark script will automatically use Apache Bench via Docker if it's not installed locally:

```bash
# Or install it manually
# Ubuntu/Debian
sudo apt-get install apache2-utils

# macOS
brew install httpd

# Alpine
apk add apache2-utils
```

## Additional Tools

For more advanced benchmarking, consider:

- **wrk**: Higher performance HTTP benchmarking
- **hey**: Modern load generator written in Go
- **siege**: Multi-threaded HTTP load testing
- **k6**: Modern load testing tool with scripting

Example with wrk:

```bash
# Install wrk
sudo apt-get install wrk

# Benchmark
wrk -t12 -c400 -d30s http://localhost:8080/index.php
wrk -t12 -c400 -d30s http://localhost:8081/index.php
```
