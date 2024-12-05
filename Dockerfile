# Base image
FROM php:7.4.0-apache

RUN docker-php-ext-install pdo_mysql

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



# Set Apache DocumentRoot to public directory
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Add wait-for-it script to ensure the database is ready
RUN curl -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
    && chmod +x /usr/local/bin/wait-for-it.sh

# Expose port 80
EXPOSE 80

VOLUME ["/var/www/html/storage/app"]

# Start the application
CMD ["bash", "-c", "wait-for-it.sh db:3306 -- php artisan migrate:fresh --force && php artisan db:seed --force && php artisan cache:clear && php artisan view:clear && php artisan route:clear && apache2-foreground"]
