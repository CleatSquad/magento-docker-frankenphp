#!/bin/bash
set -e

# Development entrypoint script
# Handles user ID/GID mapping for proper file permissions in development

# Default UID/GID for www-data user (matches base image)
readonly DEFAULT_UID=1000
readonly DEFAULT_GID=1000

# Map www-data user to host user ID if different from default
if [ -n "${USER_ID}" ] && [ "${USER_ID}" != "${DEFAULT_UID}" ]; then
    echo "Changing www-data UID to ${USER_ID}..."
    usermod -u "${USER_ID}" www-data 2>/dev/null || true
fi

# Map www-data group to host group ID if different from default
if [ -n "${GROUP_ID}" ] && [ "${GROUP_ID}" != "${DEFAULT_GID}" ]; then
    echo "Changing www-data GID to ${GROUP_ID}..."
    groupmod -g "${GROUP_ID}" www-data 2>/dev/null || true
fi

# Update ownership of working directories if IDs were changed
if [ -n "${USER_ID}" ] || [ -n "${GROUP_ID}" ]; then
    chown -R www-data:www-data /var/www /data 2>/dev/null || true
fi

# Start FrankenPHP as www-data user
exec gosu www-data frankenphp run --config /etc/caddy/Caddyfile
