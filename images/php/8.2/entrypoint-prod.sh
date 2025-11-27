#!/bin/bash
set -e
exec gosu www-data frankenphp run --config /etc/caddy/Caddyfile
