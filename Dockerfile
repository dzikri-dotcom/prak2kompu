# Gunakan PHP 8.2 dengan Apache
FROM php:8.2-apache

# Install ekstensi dan dependency Laravel
RUN apt-get update && apt-get install -y \
    git unzip zip libpng-dev libonig-dev libxml2-dev curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer dari image resmi
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Set direktori kerja
WORKDIR /var/www/html

# Copy semua file ke dalam container
COPY . .

# Install dependency Laravel
RUN composer install --no-dev --optimize-autoloader

# Ubah permission agar Laravel bisa menulis log & cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 untuk Apache
EXPOSE 80

# Jalankan Apache
CMD ["apache2-foreground"]
