# Use official PHP image with necessary extensions

FROM php:8.2-fpm

# Set working directory

WORKDIR /var/www/html

# Install system dependencies and PHP extensions

RUN apt-get update && apt-get install -y
git
unzip
libsqlite3-dev
libpng-dev
libonig-dev
curl
&& docker-php-ext-install pdo pdo_sqlite mbstring tokenizer xml

# Install Composer

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy project files

COPY . .

# Set proper permissions for storage and cache directories

RUN chmod -R 775 storage bootstrap/cache || true

# Install dependencies for production

RUN composer install --no-dev --optimize-autoloader

# Cache Laravel configuration and routes

RUN php artisan config:cache && php artisan route:cache && php artisan view:cache

# Expose port 8000

EXPOSE 8000

# Start Laravel’s built-in web server

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
