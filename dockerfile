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
    bash \
    && docker-php-ext-install pdo pdo_sqlite

# Install Node.js (for Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node -v \
    && npm -v

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Copy entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install PHP dependencies (no dev, optimized autoloader)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction --no-scripts

# Expose port 10000 for Render
EXPOSE 10000

# Use entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
