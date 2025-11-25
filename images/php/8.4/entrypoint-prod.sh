#!/bin/sh
set -e

# Fix Magento permissions for www-data
[ -f bin/magento ] && chmod +x bin/magento
# Ownership and most permissions are set at build time via Dockerfile.
# Only ensure writable directories have correct permissions if they exist.
[ -d /var/www/html/var ] && chmod -R 775 /var/www/html/var
[ -d /var/www/html/generated ] && chmod -R 775 /var/www/html/generated
[ -d /var/www/html/pub/static ] && chmod -R 775 /var/www/html/pub/static
[ -d /var/www/html/pub/media ] && chmod -R 775 /var/www/html/pub/media

# If running as root, switch to www-data
if [ "$(id -u)" = "0" ]; then
    exec su www-data -c "frankenphp run --config /etc/caddy/Caddyfile --watch"
fi

# Otherwise start normally
exec frankenphp run --config /etc/caddy/Caddyfile --watch
