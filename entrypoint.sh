#!/bin/sh

# Exit on any error
set -e

echo "🚀 Starting Laravel container setup..."

# Ensure .env exists
if [ ! -f .env ]; then
  echo "⚙️  No .env file found. Copying from .env.example..."
  cp .env.example .env
fi

# Generate app key if not set
if ! grep -q "APP_KEY=base64:" .env; then
  echo "🔑 Generating Laravel APP_KEY..."
  php artisan key:generate --ansi || true
fi

# Ensure SQLite database file exists
if [ "$DB_CONNECTION" = "sqlite" ]; then
  echo "🗄️  Ensuring SQLite database file exists..."
  mkdir -p database
  touch database/database.sqlite
  chmod 777 database/database.sqlite
fi

# Run migrations
echo "🧩 Running migrations..."
php artisan migrate --force --seed || true

# Check if Vite manifest exists
if [ ! -f "public/build/manifest.json" ]; then
  echo "⚡ No Vite manifest found. Running build again..."
  npm install --legacy-peer-deps
  npm run build
else
  echo "✅ Found existing Vite manifest."
fi

# Verify the manifest again after build
if [ ! -f "public/build/manifest.json" ]; then
  echo "❌ ERROR: Vite manifest still not found after build!"
  exit 1
fi

# Clear caches and optimize Laravel
echo "🧹 Clearing and caching Laravel configuration..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize

# Start Laravel server
echo "🌐 Starting Laravel development server on port 10000..."
exec php artisan serve --host=0.0.0.0 --port=10000
