# Base image
FROM php:7.4.0-apache

RUN apt-get update && apt-get install -y \
    git unzip zip libzip-dev libjpeg-dev libpng-dev libfreetype6-dev libmagickwand-dev --no-install-recommends \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install pdo_mysql exif zip gd


# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache mod_rewrite
RUN a2enmod rewrite


# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Set ownership and permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache


# Fix Laravel public/storage symlink (important for file manager)
RUN php artisan storage:link || echo "storage link already exists"

# Increase PHP upload limits
RUN echo "upload_max_filesize = 100M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 150M" >> /usr/local/etc/php/conf.d/uploads.ini



# Set Apache DocumentRoot to public directory
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Add wait-for-it script to ensure the database is ready
RUN curl -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

# Expose port 80
EXPOSE 80

VOLUME ["/var/www/html/storage/app"]


# Start the application
CMD bash -c "\
    rm -f composer.lock && \
    composer install && \
    php artisan config:clear && \
    php artisan cache:clear && \
    php artisan view:clear && \
    php artisan storage:link && \
    chmod -R 775 storage bootstrap/cache && \
    wait-for-it.sh db:3306 -- php artisan db:seed --force && \
    php artisan db:seed --force && \
    apache2-foreground"
