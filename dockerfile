# -----------------------------
# Stage 1: Build dependencies
# -----------------------------
FROM composer:2 AS vendor

WORKDIR /app

# Copy only composer files first (for caching)
COPY composer.json composer.lock ./

# Install PHP dependencies (no dev, optimized autoloader)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction


# -----------------------------
# Stage 2: Build Application
# -----------------------------
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install required system packages
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    unzip \
    curl \
    git \
    && docker-php-ext-install pdo pdo_sqlite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy vendor dependencies from the Composer build stage
COPY --from=vendor /app/vendor ./vendor

# Copy project files
COPY . .

# Ensure database directory exists with proper permissions
RUN mkdir -p /var/app/database && touch /var/app/database/database.sqlite \
    && chown -R www-data:www-data /var/app

# Set environment variables
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=/var/app/database/database.sqlite

# Expose Laravel port
EXPOSE 8000

# Run migrations and start the server
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
