# Use the official PHP 8.2 FPM image

FROM php:8.2-fpm

# Set working directory

WORKDIR /var/www/html

# Install system dependencies

RUN apt-get update && apt-get install -y
curl
git
unzip
libsqlite3-dev
gnupg
&& docker-php-ext-install pdo pdo_sqlite
&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x (for Laravel Vite builds)

RUN curl -fsSL [https://deb.nodesource.com/setup_22.x](https://deb.nodesource.com/setup_22.x) | bash - &&
apt-get install -y nodejs &&
npm install -g npm@latest

# Install Composer globally

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files

COPY . .

# Copy entrypoint script

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install PHP dependencies

RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-interaction

# Install Node dependencies and build Vite production assets

RUN npm install --legacy-peer-deps && npm run build

# Ensure SQLite database exists (avoid runtime missing DB)

RUN mkdir -p database && touch database/database.sqlite && chmod 777 database/database.sqlite

# Expose the Laravel app port

EXPOSE 10000

# Start Laravel via entrypoint

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
