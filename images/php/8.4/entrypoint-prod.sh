#!/bin/sh
set -e

# Fix Magento permissions for www-data
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;
chmod -R 775 /var/www/html/var
chmod -R 775 /var/www/html/generated
chmod -R 775 /var/www/html/pub/static
chmod -R 775 /var/www/html/pub/media

# If running as root, switch to www-data
if [ "$(id -u)" = "0" ]; then
    exec su www-data -c "frankenphp run --config /etc/caddy/Caddyfile --watch"
fi

# Otherwise start normally
exec frankenphp run --config /etc/caddy/Caddyfile --watch
