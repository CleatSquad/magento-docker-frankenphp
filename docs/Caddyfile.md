# Caddyfile Configuration Guide

This document explains how to configure and customize the Caddy web server for your Magento 2 FrankenPHP Docker environment.

## Table of Contents

- [Overview](#overview)
- [Template System](#template-system)
- [Environment Variables](#environment-variables)
- [Customizing the Caddyfile](#customizing-the-caddyfile)
- [SSL/TLS Configuration](#ssltls-configuration)
- [Common Customizations](#common-customizations)
- [External Resources](#external-resources)

---

## Overview

This Docker image uses [FrankenPHP](https://frankenphp.dev/), which is built on top of [Caddy](https://caddyserver.com/). The Caddyfile is the configuration file that controls how the web server handles requests.

### Image Types

| Image | SSL Behavior | Use Case |
|-------|--------------|----------|
| `base` | Standard Caddy SSL (automatic HTTPS) | Production |
| `dev` | Self-signed SSL via mkcert | Development |

---

## Template System

The Caddyfile uses a template system that allows you to customize the configuration without rebuilding the image.

### Default Template Location

```
/etc/caddy/Caddyfile.template
```

### How It Works

1. At container startup, the entrypoint script copies the template to `/etc/caddy/Caddyfile`
2. Caddy processes environment variable placeholders at runtime
3. You can mount your own template to override the default configuration

### Mounting a Custom Template

```yaml
# docker-compose.yml
services:
  app:
    image: mohelmrabet/magento-frankenphp:dev
    volumes:
      - ./my-custom-Caddyfile.template:/etc/caddy/Caddyfile.template:ro
```

---

## Environment Variables

The Caddyfile template supports the following environment variables:

### Core Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | `localhost` | The server hostname(s). Supports multiple domains separated by spaces. |
| `CADDY_GLOBAL_OPTIONS` | (empty) | Global Caddy options in the top-level block |
| `FRANKENPHP_CONFIG` | (empty) | FrankenPHP-specific configuration |
| `CADDY_EXTRA_CONFIG` | (empty) | Additional configuration blocks outside the server block |
| `CADDY_SERVER_EXTRA_DIRECTIVES` | (empty) | Extra directives inside the server block |

### Dev Image Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ENABLE_SSL_DEV` | `true` | Enable/disable self-signed SSL certificate generation |

### Examples

```yaml
# docker-compose.yml
services:
  app:
    image: mohelmrabet/magento-frankenphp:dev
    environment:
      - SERVER_NAME=magento.local
      - CADDY_GLOBAL_OPTIONS=debug
```

```yaml
# Multiple domains
environment:
  - SERVER_NAME=magento.local www.magento.local admin.magento.local
```

---

## SSL/TLS Configuration

### Development (dev image)

The dev image automatically generates self-signed SSL certificates using [mkcert](https://github.com/FiloSottile/mkcert).

#### Trusting the Certificate on Your Host

To avoid browser warnings, you can trust the mkcert CA on your host machine:

1. **Install mkcert on your host:**
   ```bash
   # macOS
   brew install mkcert
   
   # Ubuntu/Debian
   apt install mkcert
   
   # Windows (with Chocolatey)
   choco install mkcert
   ```

2. **Install the CA:**
   ```bash
   mkcert -install
   ```

3. **Share the CA with the container:**
   ```yaml
   services:
     app:
       image: mohelmrabet/magento-frankenphp:dev
       volumes:
         - "$(mkcert -CAROOT):/root/.local/share/mkcert:ro"
   ```

#### Disabling Self-Signed SSL

```yaml
environment:
  - ENABLE_SSL_DEV=false
```

### Production (base image)

For production, Caddy handles SSL automatically via Let's Encrypt. Configure your domain:

```yaml
environment:
  - SERVER_NAME=yourdomain.com www.yourdomain.com
```

For custom SSL certificates:

```yaml
volumes:
  - ./certs/cert.pem:/data/caddy/certificates/custom/cert.pem:ro
  - ./certs/key.pem:/data/caddy/certificates/custom/key.pem:ro
environment:
  - CADDY_SERVER_EXTRA_DIRECTIVES=tls /data/caddy/certificates/custom/cert.pem /data/caddy/certificates/custom/key.pem
```

---

## Common Customizations

### Adding Custom Headers

```yaml
environment:
  - CADDY_SERVER_EXTRA_DIRECTIVES=header X-Custom-Header "MyValue"
```

### Enabling Debug Mode

```yaml
environment:
  - CADDY_GLOBAL_OPTIONS=debug
```

### Configuring HTTP/3

HTTP/3 is enabled by default in Caddy. To disable it:

```yaml
environment:
  - CADDY_GLOBAL_OPTIONS=servers { protocols h1 h2 }
```

### Adding Basic Authentication

Create a custom template with basic auth:

```caddyfile
{$SERVER_NAME:localhost} {
    # ... existing config ...
    
    handle /admin/* {
        basicauth {
            admin $2a$14$hashedpassword
        }
    }
}
```

Generate password hash:
```bash
docker run --rm caddy caddy hash-password --plaintext "your-password"
```

### Rate Limiting

```yaml
environment:
  - CADDY_SERVER_EXTRA_DIRECTIVES=rate_limit {remote.ip} 100r/m
```

### Custom Error Pages

The default template already handles 404 and 503 errors. To customize:

```caddyfile
handle_errors {
    @404 {
        expression {http.error.status_code} == 404
    }
    rewrite @404 /errors/404.php
    
    @500 {
        expression {http.error.status_code} >= 500
    }
    rewrite @500 /errors/500.html
}
```

---

## Full Custom Caddyfile Example

Here's a complete example of a custom Caddyfile template:

```caddyfile
# Custom Caddyfile for Magento 2 + FrankenPHP
{
    # Enable debug logging
    debug
    
    frankenphp {
        # FrankenPHP configuration
    }
    
    order php_server before file_server
}

# Define maintenance mode snippet
(maintenance) {
    @maintenance file /var/www/html/var/.maintenance.flag
    handle @maintenance {
        respond "Site under maintenance" 503
    }
}

{$SERVER_NAME:localhost} {
    # Import maintenance mode
    import maintenance
    
    log {
        output stdout
        level INFO
    }
    
    root * /var/www/html/pub
    encode zstd br gzip
    
    # Security headers
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        Permissions-Policy "browsing-topics=()"
    }
    
    # Block sensitive files
    @sensitiveFiles {
        path_regexp sensitive /(\.user.ini|\.php$|\.phtml$|\.htaccess$|\.htpasswd$|\.git)
    }
    respond @sensitiveFiles 403
    
    php_server
    
    # Static files caching
    @staticFiles {
        path *.ico *.jpg *.jpeg *.png *.gif *.svg *.webp *.js *.css *.woff *.woff2
    }
    handle @staticFiles {
        header Cache-Control "public, max-age=31536000"
    }
    
    # Media handling
    handle /media/* {
        try_files {path} {path}/ /get.php{query}
    }
    
    # Static files handling
    @staticPath path_regexp reg_static ^/static/(version\d*/)?(.*)$
    handle @staticPath {
        @static file /static/{re.reg_static.2}
        rewrite @static /static/{re.reg_static.2}
        @dynamic not file /static/{re.reg_static.2}
        rewrite @dynamic /static.php?resource={re.reg_static.2}
    }
}
```

---

## External Resources

### Caddy Documentation

- 📚 [Caddyfile Concepts](https://caddyserver.com/docs/caddyfile/concepts)
- 📚 [Caddyfile Directives](https://caddyserver.com/docs/caddyfile/directives)
- 📚 [Caddy Placeholders](https://caddyserver.com/docs/caddyfile/concepts#placeholders)
- 📚 [TLS Configuration](https://caddyserver.com/docs/caddyfile/directives/tls)
- 📚 [Automatic HTTPS](https://caddyserver.com/docs/automatic-https)

### FrankenPHP Documentation

- 📚 [FrankenPHP Documentation](https://frankenphp.dev/docs/)
- 📚 [FrankenPHP Configuration](https://frankenphp.dev/docs/config/)
- 📚 [Worker Mode](https://frankenphp.dev/docs/worker/)

### mkcert Documentation

- 📚 [mkcert GitHub](https://github.com/FiloSottile/mkcert)
- 📚 [mkcert Installation](https://github.com/FiloSottile/mkcert#installation)

### Magento 2 Resources

- 📚 [Magento 2 DevDocs](https://developer.adobe.com/commerce/docs/)
- 📚 [Magento Security Best Practices](https://experienceleague.adobe.com/docs/commerce-operations/implementation-playbook/best-practices/launch/security-best-practices.html)

---

## Troubleshooting

### SSL Certificate Issues

**Problem:** Browser shows "Not Secure" warning

**Solution:** Install mkcert CA on your host machine (see [SSL/TLS Configuration](#ssltls-configuration))

### Configuration Not Applied

**Problem:** Changes to environment variables not taking effect

**Solution:** 
1. Restart the container: `docker compose restart app`
2. Verify the Caddyfile: `docker compose exec app cat /etc/caddy/Caddyfile`

### Debug Caddy Configuration

```bash
# Validate Caddyfile syntax
docker compose exec app frankenphp validate --config /etc/caddy/Caddyfile

# Check Caddy logs
docker compose logs app | grep -i caddy
```

### Permission Issues

```bash
# Fix permissions on Caddy data
docker compose exec app chown -R www-data:www-data /data/caddy /etc/caddy
```
