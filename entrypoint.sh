#!/bin/sh

# Exit on error
set -e

# Ensure .env exists
if [ ! -f .env ]; then
  cp .env.example .env
fi

# Generate APP_KEY if missing
grep -q "APP_KEY=base64:" .env || php artisan key:generate --ansi

# Ensure SQLite database exists
[ "$DB_CONNECTION" = "sqlite" ] && mkdir -p database && touch database/database.sqlite && chmod 777 database/database.sqlite

# Ensure storage & cache directories exist
mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache
chmod -R 777 storage bootstrap/cache

# Run migrations & seed safely
php artisan migrate --force --seed || true

# Run Composer post-autoload-dump
composer run-script post-autoload-dump || true

# Build Vite assets if manifest is missing
[ ! -f "public/build/manifest.json" ] && npm ci --legacy-peer-deps && npm run build

# Verify Vite manifest exists
[ ! -f "public/build/manifest.json" ] && echo "❌ Vite manifest missing!" && exit 1

# Clear and cache configs safely
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Start Laravel server on port 10000
php artisan serve --host=0.0.0.0 --port=10000
