#!/bin/bash
set -e

if [ -n "$USER_ID" ] && [ "$USER_ID" != "1000" ]; then
    echo "Changing www-data UID to $USER_ID..."
    usermod -u $USER_ID www-data 2>/dev/null || true
fi

if [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "1000" ]; then
    echo "Changing www-data GID to $GROUP_ID..."
    groupmod -g $GROUP_ID www-data 2>/dev/null || true
fi

if [ -n "$USER_ID" ] || [ -n "$GROUP_ID" ]; then
    chown -R www-data:www-data /var/www /data 2>/dev/null || true
fi

exec gosu www-data frankenphp run --config /etc/caddy/Caddyfile
