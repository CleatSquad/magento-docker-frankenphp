#!/bin/bash
set -e

############################################
# FIX : Always run from the project root
############################################
cd "$(dirname "$0")/.."

echo "🚀 Setting up Magento Docker environment..."

############################################
# 1) Create Docker network if needed
############################################
if ! docker network ls | grep -q "proxy" ; then
    echo "📡 Creating proxy network..."
    docker network create proxy
    echo "✅ Network 'proxy' created"
else
    echo "✅ Network 'proxy' already exists"
fi

############################################
# 2) Prepare env files
############################################
echo "📝 Setting up environment files..."



# Ensure env directory exists
if [ ! -d "env" ]; then
    echo "❌ ERROR: The 'env' directory does not exist!"
    exit 1
fi

# magento.env
if [ ! -f ".env" ] && [ -f "env/magento.env.example" ]; then
    cp env/magento.env.example .env
    echo "✅ Created .env"
fi

# mariadb.env
if [ ! -f "../env/mariadb.env" ] && [ -f "../env/mariadb.env.example" ]; then
    cp ../env/mariadb.env.example ../env/mariadb.env
    echo "✅ Created env/mariadb.env"
fi

# opensearch.env
if [ ! -f "env/opensearch.env" ] && [ -f "env/opensearch.env.example" ]; then
    cp env/opensearch.env.example env/opensearch.env
    echo "✅ Created env/opensearch.env"
fi

# rabbitmq.env
if [ ! -f "env/rabbitmq.env" ] && [ -f "env/rabbitmq.env.example" ]; then
    cp env/rabbitmq.env.example env/rabbitmq.env
    echo "✅ Created env/rabbitmq.env"
fi

# valkey.env
if [ ! -f "env/valkey.env" ] && [ -f "env/valkey.env.example" ]; then
    cp env/valkey.env.example env/valkey.env
    echo "✅ Created env/valkey.env"
fi

############################################
# 3) Append USER_ID & GROUP_ID to .env
############################################
echo "👤 Setting up user permissions..."

if ! grep -q "USER_ID=" .env ; then
    echo "USER_ID=$(id -u)" >> .env
fi

if ! grep -q "GROUP_ID=" .env ; then
    echo "GROUP_ID=$(id -g)" >> .env
fi

echo "✅ USER_ID=$(id -u), GROUP_ID=$(id -g) added to .env"


############################################
# 4) Finish
############################################
echo ""
echo "🎉 Setup complete!"
echo ""
echo "Start with:"
echo "  docker compose up -d                       # Development"
echo "  docker compose -f docker-compose.prod.yml up -d   # Production"
