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

# Copy project files
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install PHP dependencies (no dev, optimized autoloader)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction --no-scripts

# Expose the desired port
EXPOSE 10000

# Use entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
