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

# Double-check that manifest.json exists
if [ ! -f "public/build/manifest.json" ]; then
  echo "❌ ERROR: Vite manifest not found after build!"
  exit 1
fi

# Clear caches and optimize
echo "🧹 Optimizing Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start the Laravel development server
echo "🌐 Starting Laravel server on port 10000..."
php artisan serve --host=0.0.0.0 --port=10000
