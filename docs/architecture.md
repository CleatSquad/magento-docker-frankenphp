# Architecture Overview

This document describes the architecture of the Magento FrankenPHP Docker stack.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Client Browser                                  │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS (443) / HTTP (80)
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         TRAEFIK REVERSE PROXY (Dev)                         │
│                    or CADDY BUILT-IN (Prod)                                 │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  • Automatic HTTPS/TLS termination                                    │   │
│  │  • Load balancing                                                     │   │
│  │  • Request routing                                                    │   │
│  │  • Health checks                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FRANKENPHP APPLICATION SERVER                         │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                          CADDY WEB SERVER                             │   │
│  │  • Static file serving                                                │   │
│  │  • PHP request handling                                               │   │
│  │  • Security headers                                                   │   │
│  │  • Gzip compression                                                   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         FRANKENPHP ENGINE                             │   │
│  │  • PHP 8.2/8.3/8.4                                                    │   │
│  │  • Worker mode (persistent processes)                                 │   │
│  │  • OPcache optimized                                                  │   │
│  │  • All Magento extensions                                             │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         MAGENTO 2 APPLICATION                         │   │
│  │  • /var/www/html (mounted from ./src)                                 │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
          │              │              │              │              │
          ▼              ▼              ▼              ▼              ▼
     ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
     │ MariaDB │   │OpenSearch│   │ Valkey  │   │RabbitMQ │   │ Mailhog │
     │  :3306  │   │  :9200   │   │  :6379  │   │  :5672  │   │  :8025  │
     │         │   │          │   │         │   │         │   │ (dev)   │
     │Database │   │ Search   │   │ Cache & │   │ Message │   │  Email  │
     │         │   │ Engine   │   │Sessions │   │  Queue  │   │ Catcher │
     └─────────┘   └─────────┘   └─────────┘   └─────────┘   └─────────┘
```

## Service Details

### FrankenPHP Application Server

The core of the stack, combining Caddy web server with FrankenPHP:

| Feature | Description |
|---------|-------------|
| **Worker Mode** | Persistent PHP processes for better performance |
| **OPcache** | Pre-compiled PHP bytecode for faster execution |
| **Automatic HTTPS** | Built-in TLS certificate management |
| **HTTP/2 & HTTP/3** | Modern protocol support |

### Database Layer (MariaDB)

| Feature | Description |
|---------|-------------|
| **Version** | MariaDB 11.4 LTS |
| **Port** | 3306 (internal) |
| **Storage** | Docker volume `db-data` |

### Search Engine (OpenSearch)

| Feature | Description |
|---------|-------------|
| **Version** | OpenSearch 2.14 |
| **Plugins** | analysis-icu, analysis-phonetic |
| **Port** | 9200 (internal) |
| **Mode** | Single-node (development) |

### Cache & Sessions (Valkey)

Valkey is a Redis-compatible cache server:

| Feature | Description |
|---------|-------------|
| **Version** | Valkey 8.1.4 |
| **Port** | 6379 |
| **Usage** | Cache (db0), Page Cache (db1), Sessions (db2) |

### Message Queue (RabbitMQ)

| Feature | Description |
|---------|-------------|
| **Version** | RabbitMQ 4.1 with Management |
| **Ports** | 5672 (AMQP), 15672 (Management UI) |
| **Usage** | Async message processing |

### Reverse Proxy (Traefik - Dev Only)

| Feature | Description |
|---------|-------------|
| **Version** | Traefik 3.6 |
| **Ports** | 80, 443 |
| **Features** | Auto-discovery, Dashboard |

## Network Architecture

### Development Network Layout

```
┌──────────────────────────────────────────────────────────────────┐
│                         Docker Networks                           │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    "proxy" (external)                        │ │
│  │  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐     │ │
│  │  │ traefik │   │   app   │   │rabbitmq │   │ mailhog │     │ │
│  │  └─────────┘   └─────────┘   └─────────┘   └─────────┘     │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    "magento" (internal)                      │ │
│  │  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐     │ │
│  │  │   app   │   │ mariadb │   │opensearch│   │ valkey  │     │ │
│  │  │         │   │         │   │         │   │         │     │ │
│  │  │         │   │         │   │         │   └─────────┘     │ │
│  │  │         │   └─────────┘   └─────────┘                   │ │
│  │  └─────────┘                                                │ │
│  │       │                                                     │ │
│  │       │      ┌─────────┐   ┌─────────┐                     │ │
│  │       └──────│rabbitmq │   │phpmyadmin│                     │ │
│  │              └─────────┘   └─────────┘                     │ │
│  └─────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

### Production Network Layout

```
┌──────────────────────────────────────────────────────────────────┐
│                    "magento" (internal only)                      │
│                                                                   │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐          │
│  │   app   │───│ mariadb │   │opensearch│   │ valkey  │          │
│  │  :80    │   │  :3306  │   │  :9200  │   │  :6379  │          │
│  │  :443   │   │         │   │         │   │         │          │
│  └─────────┘   └─────────┘   └─────────┘   └─────────┘          │
│       │                                                          │
│       │        ┌─────────┐                                       │
│       └────────│rabbitmq │                                       │
│                │  :5672  │                                       │
│                └─────────┘                                       │
└──────────────────────────────────────────────────────────────────┘
        │
        │ Ports 80, 443 exposed
        ▼
   [Internet]
```

## Data Flow

### HTTP Request Flow

```
1. Client Request
       │
       ▼
2. Traefik/Caddy (TLS termination, routing)
       │
       ▼
3. FrankenPHP (PHP execution)
       │
       ├──────► MariaDB (data persistence)
       │
       ├──────► OpenSearch (search queries)
       │
       ├──────► Valkey (cache lookup/session)
       │
       └──────► RabbitMQ (async jobs)
       │
       ▼
4. Response to Client
```

### Magento Cache Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                      VALKEY (Redis-compatible)               │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │    DB 0      │  │    DB 1      │  │    DB 2      │       │
│  │              │  │              │  │              │       │
│  │   Backend    │  │    Page      │  │   Session    │       │
│  │    Cache     │  │    Cache     │  │   Storage    │       │
│  │              │  │              │  │              │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

## Volume Mounts

| Volume | Container Path | Purpose |
|--------|---------------|---------|
| `./src` | `/var/www/html` | Magento source code |
| `db-data` | `/var/lib/mysql` | Database persistence |
| `opensearch-data` | `/usr/share/opensearch/data` | Search index data |
| `rabbitmq-data` | `/var/lib/rabbitmq` | Message queue data |

## Port Mappings

### Development

| Service | Internal Port | External Port | URL |
|---------|--------------|---------------|-----|
| Traefik | 80, 443 | 80, 443 | - |
| Magento | 443 | via Traefik | https://magento.localhost |
| RabbitMQ UI | 15672 | via Traefik | http://rabbit.localhost |
| Mailhog | 8025 | via Traefik | http://mailhog.localhost |
| phpMyAdmin | 80 | via Traefik | http://myadmin.localhost |
| Valkey | 6379 | 6379 | - |

### Production

| Service | Internal Port | External Port |
|---------|--------------|---------------|
| Magento | 80, 443 | 80, 443 |

## See Also

- [Getting Started](getting-started.md)
- [Configuration Guide](configuration.md)
- [Usage Scenarios](usage-scenarios.md)
- [Customization Guide](customization.md)
