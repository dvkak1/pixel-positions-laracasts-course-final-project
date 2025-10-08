# Base PHP image
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libsqlite3-dev \
    gnupg \
    && docker-php-ext-install pdo pdo_sqlite

# Install Node.js (for Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Copy and set permissions for entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install PHP dependencies (without dev packages)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# Build frontend assets
RUN npm install --legacy-peer-deps && npm run build

# Expose port
EXPOSE 10000

# Run entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
