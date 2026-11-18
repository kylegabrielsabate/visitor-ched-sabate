FROM php:8.3-cli

# Install system dependencies and PHP extensions (including PostgreSQL support)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy all project files into the container
COPY . /app

# Install PHP dependencies (production only)
RUN composer install --no-dev --optimize-autoloader

# Make sure storage and cache directories are writable
RUN chmod -R 775 storage bootstrap/cache

# Expose port
EXPOSE 8000

# Run migrations and start the server
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
