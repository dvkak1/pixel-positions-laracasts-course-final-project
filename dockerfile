# Use official PHP 8.2 FPM image
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

# Copy project files into container
COPY . .

# Copy .env.example if .env doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Install PHP dependencies without dev packages
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction --no-scripts

# Generate app key
RUN php artisan key:generate --ansi

# Ensure SQLite database exists
RUN mkdir -p database && touch database/database.sqlite && chmod 777 database/database.sqlite

# Optional: run package discovery safely
RUN composer run-script post-autoload-dump || true

# Expose port 8000
EXPOSE 8000

# Entrypoint script to handle DB and migrations, then start server
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
