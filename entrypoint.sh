#!/bin/sh

set -e

# Ensure environment setup
if [ ! -f .env ]; then
  cp .env.example .env
fi

# Generate app key if missing
php artisan key:generate --ansi || true

# Create SQLite database
mkdir -p database
touch database/database.sqlite
chmod 777 database/database.sqlite

# Clear caches to ensure fresh config/views
php artisan config:clear || true
php artisan view:clear || true
php artisan cache:clear || true

# Run migrations
php artisan migrate --force || true

# Run Composer scripts
composer run-script post-autoload-dump || true

# Start Laravel app on port 10000
php artisan serve --host=0.0.0.0 --port=10000
