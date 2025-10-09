#!/bin/sh
set -e

echo "🚀 Starting Laravel container setup..."

# Ensure .env exists
if [ ! -f .env ]; then
  cp .env.example .env
fi

# Generate app key if missing
if ! grep -q "APP_KEY=base64:" .env; then
  php artisan key:generate --ansi || true
fi

# Ensure SQLite database exists
if [ "$DB_CONNECTION" = "sqlite" ]; then
  mkdir -p database
  touch database/database.sqlite
  chmod 777 database/database.sqlite
fi

# Ensure Laravel storage & bootstrap/cache directories exist and are writable
mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
chmod -R 777 storage bootstrap/cache

# 🔹 Ensure Composer dependencies are installed
if [ ! -d "vendor" ]; then
  echo "📦 Vendor directory missing, running composer install..."
  composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction
fi

# Run migrations and seed
php artisan migrate --force --seed || true

# Ensure Composer autoload files are up to date
composer run-script post-autoload-dump || true

# 🔹 Set NODE_ENV for Vite build
export NODE_ENV=${NODE_ENV:-production}

# Build Vite assets if missing
if [ ! -f "public/build/manifest.json" ]; then
  echo "⚡ Vite manifest not found, building assets in $NODE_ENV mode..."
  npm ci --legacy-peer-deps
  npm run build
fi

# Clear caches and optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start Laravel server
php artisan serve --host=0.0.0.0 --port=10000
