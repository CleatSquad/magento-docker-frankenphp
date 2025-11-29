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

# Process Xdebug configuration
XDEBUG_TEMPLATE="/etc/php/xdebug.ini.template"
XDEBUG_TARGET="/usr/local/etc/php/conf.d/zz-xdebug.ini"

if [ -f "$XDEBUG_TEMPLATE" ]; then
    export XDEBUG_MODE="${XDEBUG_MODE:-debug}"
    export XDEBUG_CLIENT_HOST="${XDEBUG_CLIENT_HOST:-host.docker.internal}"
    export XDEBUG_CLIENT_PORT="${XDEBUG_CLIENT_PORT:-9003}"
    export XDEBUG_START_WITH_REQUEST="${XDEBUG_START_WITH_REQUEST:-trigger}"
    export XDEBUG_IDEKEY="${XDEBUG_IDEKEY:-PHPSTORM}"

    # Process template with environment variables directly to target
    # The target file must be pre-created with correct permissions in Dockerfile
    envsubst '${XDEBUG_MODE} ${XDEBUG_CLIENT_HOST} ${XDEBUG_CLIENT_PORT} ${XDEBUG_START_WITH_REQUEST} ${XDEBUG_IDEKEY}' \
        < "$XDEBUG_TEMPLATE" > "$XDEBUG_TARGET"

    echo "🐛 Xdebug configured:"
    echo "    mode=${XDEBUG_MODE}"
    echo "    host=${XDEBUG_CLIENT_HOST}"
    echo "    port=${XDEBUG_CLIENT_PORT}"
fi

# Display SSL information
SSL_DOMAIN="${SERVER_NAME:-localhost}"
SSL_DOMAIN=$(echo "$SSL_DOMAIN" | sed -E 's|^https?://||' | sed -E 's|:[0-9]+$||')

echo "🔐 SSL Mode: ${CADDY_TLS_CONFIG:-internal}"
echo "🌐 Server Name: $SSL_DOMAIN"

# If using internal TLS (default), Caddy will auto-generate self-signed certificates
if [ "${CADDY_TLS_CONFIG:-internal}" = "internal" ]; then
    echo "📌 Using Caddy's internal TLS (self-signed certificates)"
    echo "   To trust certificates in your browser, either:"
    echo "   1. Accept the certificate manually (click Advanced → Proceed)"
    echo "   2. Or run './bin/setup-ssl' on the host to generate trusted certificates"
fi

# Start FrankenPHP
if [ $# -eq 0 ]; then
    exec frankenphp run --config /etc/caddy/Caddyfile --watch
fi

exec "$@"
