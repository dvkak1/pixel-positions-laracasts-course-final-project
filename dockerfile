# Use official PHP image
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_sqlite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files into the container
COPY . .

# Copy environment file if not present
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Install PHP dependencies (no dev, optimized, no scripts yet)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction --no-scripts

# Generate Laravel app key
RUN php artisan key:generate --ansi

# Ensure SQLite database exists
RUN mkdir -p /var/www/html/database && \
    touch /var/www/html/database/database.sqlite && \
    chmod 777 /var/www/html/database/database.sqlite

# Run package discovery scripts
RUN composer run-script post-autoload-dump || true

# Expose port 10000 for Render
EXPOSE 10000

# Start Laravel server on port 10000
CMD php artisan serve --host=0.0.0.0 --port=10000
