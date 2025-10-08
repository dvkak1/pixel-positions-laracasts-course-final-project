#!/bin/sh

# Exit immediately on error
set -e

echo "🚀 Starting Laravel container setup..."

# Ensure .env exists
if [ ! -f .env ]; then
  echo "⚙️  No .env file found. Copying from .env.example..."
  cp .env.example .env
fi

# Generate app key if not present
if ! grep -q "APP_KEY=base64:" .env; then
  echo "🔑 Generating new Laravel APP_KEY..."
  php artisan key:generate --ansi || true
fi

# Ensure SQLite database exists
if [ "$DB_CONNECTION" = "sqlite" ]; then
  echo "🗄️  Ensuring SQLite database file exists..."
  mkdir -p database
  touch database/database.sqlite
  chmod 777 database/database.sqlite
fi

# Refresh Composer autoload before migrations (prevents fake() undefined)
echo "📦 Refreshing Composer autoload..."
composer dump-autoload

# Ensure storage and bootstrap/cache directories exist
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p bootstrap/cache

# Make them writable
chmod -R 777 storage
chmod -R 777 bootstrap/cache

# Run migrations and seed (if available)
echo "🧩 Running migrations..."
php artisan migrate --force --seed || true

# Ensure Composer autoload files are up to date
echo "📦 Running Composer post-autoload-dump..."
composer run-script post-autoload-dump || true

# Install Node dependencies and build (if build missing)
if [ ! -f "public/build/manifest.json" ]; then
  echo "⚡ Vite build not found, building assets..."
  npm ci --legacy-peer-deps
  npm run build
else
  echo "✅ Found existing Vite build."
fi

# Clear caches and optimize, skip if paths missing
echo "🧹 Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:clear || true
php artisan view:cache || true

# Start the Laravel development server
echo "🌐 Starting Laravel server on port 10000..."
php artisan serve --host=0.0.0.0 --port=10000
