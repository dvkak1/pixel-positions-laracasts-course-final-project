#!/bin/bash
set -e

# Navigate to working directory (should match Dockerfile WORKDIR)
cd /var/www/html

# Copy .env.example to .env if .env does not exist
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate APP_KEY if not set
if ! grep -q 'APP_KEY=' .env || [ -z "$(grep 'APP_KEY=' .env | cut -d '=' -f2)" ]; then
    php artisan key:generate --ansi
fi

# Ensure SQLite database directory & file exist
mkdir -p /var/app/database
if [ ! -f /var/app/database/database.sqlite ]; then
    touch /var/app/database/database.sqlite
    chmod 777 /var/app/database/database.sqlite
fi

# Run migrations and seed (ignore errors if already migrated)
php artisan migrate --force || true
php artisan db:seed --force || true

# Run Composer post-autoload scripts
composer run-script post-autoload-dump || true

# Start Laravel server on 0.0.0.0:10000
php artisan serve --host=0.0.0.0 --port=10000
