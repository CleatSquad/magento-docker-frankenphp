#!/bin/bash
set -e

# Process Caddyfile template
# If a custom template is mounted, use it; otherwise use the default
TEMPLATE_SOURCE="/etc/caddy/Caddyfile.template"
CADDYFILE_TARGET="/etc/caddy/Caddyfile"

# Check if template exists (either mounted or default)
if [ -f "$TEMPLATE_SOURCE" ]; then
    # Copy template to target (allows environment variable substitution by Caddy)
    cp "$TEMPLATE_SOURCE" "$CADDYFILE_TARGET"
    echo "📝 Caddyfile template processed: $TEMPLATE_SOURCE -> $CADDYFILE_TARGET"
fi

# Generate self-signed SSL certificate for development using mkcert
# This runs only if mkcert is available (dev image) and ENABLE_SSL_DEV is set
if command -v mkcert &> /dev/null && [ "${ENABLE_SSL_DEV:-true}" = "true" ]; then
    SSL_DOMAIN="${SERVER_NAME:-localhost}"
    SSL_DIR="/data/caddy/certificates/local"
    
    # Extract domain (remove port and protocol if present)
    SSL_DOMAIN=$(echo "$SSL_DOMAIN" | sed -E 's|^https?://||' | sed -E 's|:[0-9]+$||')
    
    # Initialize mkcert CA if not already done
    MKCERT_CAROOT=$(mkcert -CAROOT 2>/dev/null || echo "/root/.local/share/mkcert")
    if [ ! -f "$MKCERT_CAROOT/rootCA.pem" ]; then
        echo "🔐 Initializing mkcert local CA..."
        mkcert -install 2>/dev/null || true
    fi
    
    # Generate certificate if not exists
    mkdir -p "$SSL_DIR"
    if [ ! -f "$SSL_DIR/${SSL_DOMAIN}.pem" ]; then
        echo "🔐 Generating self-signed SSL certificate for: $SSL_DOMAIN"
        mkcert -cert-file "$SSL_DIR/${SSL_DOMAIN}.pem" \
               -key-file "$SSL_DIR/${SSL_DOMAIN}-key.pem" \
               "$SSL_DOMAIN" "*.${SSL_DOMAIN}" localhost 127.0.0.1 ::1
        
        # Fix permissions
        chown -R www-data:www-data "$SSL_DIR" 2>/dev/null || true
        chmod 644 "$SSL_DIR"/*.pem 2>/dev/null || true
    fi
    
    echo "✅ Self-signed SSL certificate ready for: $SSL_DOMAIN"
    echo "📌 To trust this certificate on your host, install the CA from:"
    echo "   Container path: $MKCERT_CAROOT/rootCA.pem"
    echo "   Or mount your host's mkcert CA to the container"
fi

# Start FrankenPHP
if [ $# -eq 0 ]; then
    exec frankenphp run --config /etc/caddy/Caddyfile --watch
fi

exec "$@"
