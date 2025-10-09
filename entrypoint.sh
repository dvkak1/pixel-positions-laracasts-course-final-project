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

# Ensure storage & bootstrap/cache directories exist and are writable
mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
chmod -R 777 storage bootstrap/cache

# Run migrations & seed
php artisan migrate --force --seed || true

# Ensure Composer autoload files are up to date
composer run-script post-autoload-dump || true

# Build Vite assets **always** on container startup
echo "⚡ Building Vite assets..."
npm ci --legacy-peer-deps
npm run build

# Clear caches & optimize
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start Laravel server
php artisan serve --host=0.0.0.0 --port=10000
