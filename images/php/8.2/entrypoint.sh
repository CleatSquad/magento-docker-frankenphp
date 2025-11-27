#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    exec frankenphp run --config /etc/caddy/Caddyfile --watch
fi

exec "$@"
