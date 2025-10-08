# -------------------------------------------
# 🐘 Stage 1 — PHP with Composer
# -------------------------------------------
FROM php:8.2-fpm AS php-base

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libsqlite3-dev \
    gnupg \
    && docker-php-ext-install pdo pdo_sqlite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# -------------------------------------------
# 🧱 Stage 2 — Node build for Vite assets
# -------------------------------------------
FROM node:22 AS node-build

WORKDIR /app

# Copy only necessary files for dependency installation
COPY package*.json ./

# Install and build assets using lockfile
RUN npm ci --legacy-peer-deps

# Copy the rest of the project files for the build
COPY . .

# Build Vite assets for production
RUN npm run build


# -------------------------------------------
# 🚀 Stage 3 — Final runtime image
# -------------------------------------------
FROM php-base AS runtime

WORKDIR /var/www/html

# Copy project files
COPY . .

# Copy built Vite assets from Node build stage
COPY --from=node-build /app/public/build ./public/build

# Copy and enable entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install PHP dependencies (optimized)
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# Expose Laravel port
EXPOSE 10000

# Run entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
