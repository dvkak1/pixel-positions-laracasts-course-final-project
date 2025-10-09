#!/bin/sh

set -e

echo "🚀 Starting Laravel container setup..."

# Use production environment if exists
if [ -f .env.production ]; then
    echo "⚙️  Using .env.production"
    cp .env.production .env
fi

# Generate app key if missing
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating Laravel APP_KEY..."
    php artisan key:generate --ansi || true
fi

# Ensure SQLite database exists
if [ "$DB_CONNECTION" = "sqlite" ]; then
    echo "🗄️  Ensuring SQLite database file exists..."
    mkdir -p database
    touch database/database.sqlite
    chmod 777 database/database.sqlite
fi

# Run migrations and seed database
echo "🧩 Running migrations..."
php artisan migrate --force --seed || true

# Composer post-autoload-dump
echo "📦 Running Composer post-autoload-dump..."
composer run-script post-autoload-dump || true

# Build Vite assets if manifest missing
if [ ! -f "public/build/manifest.json" ]; then
    echo "⚡ Building Vite assets..."
    npm ci --legacy-peer-deps
    npm run build
else
    echo "✅ Vite manifest found, skipping build."
fi

# Clear caches and optimize
echo "🧹 Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start Laravel server on port 10000
echo "🌐 Starting Laravel server..."
php artisan serve --host=0.0.0.0 --port=10000
