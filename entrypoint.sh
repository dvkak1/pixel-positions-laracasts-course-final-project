#!/bin/sh
set -ex  # Exit on error & show each command for debugging

echo "🚀 Starting Laravel container setup..."

# Ensure .env exists
if [ ! -f .env ]; then
  echo "⚙️  No .env file found. Copying from .env.example..."
  cp .env.example .env
fi

# Generate app key if missing
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

# Run migrations and seed database (ignore failure if tables exist)
echo "🧩 Running migrations..."
php artisan migrate --force --seed || true

# Composer post-autoload-dump
echo "📦 Running Composer post-autoload-dump..."
composer run-script post-autoload-dump || true

# Build assets only if missing
if [ ! -f "public/build/manifest.json" ]; then
  echo "⚡ Building Vite assets..."
  npm ci --legacy-peer-deps
  npm run build
else
  echo "✅ Existing Vite build found."
fi

# Verify build output
if [ ! -f "public/build/manifest.json" ]; then
  echo "❌ ERROR: Vite manifest not found after build!"
  exit 1
fi

# Cache optimizations
echo "🧹 Optimizing Laravel..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Start Laravel server on the Render-assigned port
PORT=${PORT:-10000}
echo "🌐 Starting Laravel server on port ${PORT}..."
php artisan serve --host=0.0.0.0 --port=${PORT}
