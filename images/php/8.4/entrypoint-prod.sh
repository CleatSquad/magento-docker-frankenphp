#!/bin/bash
set -e

# Production entrypoint script
# Runs FrankenPHP as www-data user for security

exec gosu www-data frankenphp run --config /etc/caddy/Caddyfile
