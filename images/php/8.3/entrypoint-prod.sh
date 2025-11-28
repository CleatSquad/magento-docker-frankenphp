#!/bin/bash
set -e

# Process Caddyfile template
TEMPLATE_SOURCE="/etc/caddy/Caddyfile.template"
CADDYFILE_TARGET="/etc/caddy/Caddyfile"

if [ -f "$TEMPLATE_SOURCE" ]; then
    cp "$TEMPLATE_SOURCE" "$CADDYFILE_TARGET"
fi

exec frankenphp run --config /etc/caddy/Caddyfile
