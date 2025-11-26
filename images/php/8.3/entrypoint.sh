#!/bin/sh
set -e

# If running as root, switch to user "app"
if [ "$(id -u)" = "0" ]; then
    exec su app -c "frankenphp run --config /etc/caddy/Caddyfile --watch"
fi

# Otherwise start normally
exec frankenphp run --config /etc/caddy/Caddyfile --watch
