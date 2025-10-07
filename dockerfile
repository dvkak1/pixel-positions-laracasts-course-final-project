# Use official PHP image
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_sqlite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Copy environment file (avoid missing .env issues)
RUN cp .env.example .env

# Install PHP dependencies safely (ignore scripts at build time)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction --no-scripts

# Generate Laravel app key
RUN php artisan key:generate

# Create SQLite database directory & file
RUN mkdir -p database && touch database/database.sqlite && chmod 777 database/database.sqlite

# Run package discovery AFTER install
RUN composer run-script post-autoload-dump

# Expose port
EXPOSE 8000

# Start Laravel app
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
