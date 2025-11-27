#!/bin/bash
set -e
exec frankenphp run --config /etc/caddy/Caddyfile
