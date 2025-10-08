#!/bin/sh

# Exit immediately on error

set -e

echo "🚀 Starting Laravel container setup..."

# Use .env.production if .env doesn't exist

if [ ! -f .env ] && [ -f .env.production ]; then
echo "⚙️  Using .env.production as .env..."
cp .env.production .env
elif [ ! -f .env ]; then
echo "⚙️  No .env file found. Copying from .env.example..."
cp .env.example .env
fi

# Generate app key if not already set

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

# Run database migrations and seeders (safe fallback)

echo "🧩 Running migrations..."
php artisan migrate --force --seed || true

# Optimize Composer autoload

echo "📦 Running Composer post-autoload-dump..."
composer run-script post-autoload-dump || true

# Check if Vite build exists; build if missing

if [ ! -f "public/build/manifest.json" ]; then
echo "⚡ No Vite build found. Building assets..."
npm install --legacy-peer-deps
npm run build
else
echo "✅ Found existing Vite build."
fi

# Verify Vite manifest

if [ ! -f "public/build/manifest.json" ]; then
echo "❌ ERROR: Vite manifest not found after build!"
exit 1
fi

# Laravel optimization

echo "🧹 Clearing and caching Laravel configuration..."
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan optimize

# Start Laravel server on port 10000

echo "🌐 Starting Laravel server on port 10000..."
exec php artisan serve --host=0.0.0.0 --port=10000
