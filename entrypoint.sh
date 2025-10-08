#!/bin/sh

# Exit on error
set -e

# Copy .env.example if .env does not exist
if [ ! -f .env ]; then
  cp .env.example .env
fi

# Generate Laravel app key if missing
php artisan key:generate --ansi || true

# Ensure SQLite database exists
mkdir -p database
touch database/database.sqlite
chmod 777 database/database.sqlite

# Run migrations and seed the database
php artisan migrate --force --seed || true

# Build Vite assets
npm install --legacy-peer-deps || true
npm run build || true

# Run Composer scripts (package discovery, etc.)
composer run-script post-autoload-dump || true

# Start Laravel server on port 10000
php artisan serve --host=0.0.0.0 --port=10000
