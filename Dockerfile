# Use a minimal Ubuntu base image
FROM ubuntu:22.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    libapache2-mod-php \
    apache2 \
    php-fpm \
    php-mysql \
    php-xml \
    php-gd \
    php-mbstring \
    php-curl \
    php-zip \
    php-bcmath \
    unzip \
    locales && \
    # Set the locale to avoid prompts
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    # Clean up unnecessary files to reduce image size
    rm -rf /var/lib/apt/lists/*


RUN wget https://wordpress.org/latest.tar.gz && \
  tar -xvzf latest.tar.gz && \
  mv wordpress /var/www/html/ && \
  rm latest.tar.gz

# Set correct permissions for WordPress
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Configure Nginx to serve WordPress
COPY web.conf /etc/apache2/sites-enabled/000-default.conf
COPY wp-config.php /var/www/html/wordpress/wp-config.php

RUN a2enmod rewrite
# Expose HTTP port
EXPOSE 80

# Start PHP-FPM and Nginx in the foreground using a simple shell script
# CMD ["sh", "-c", "service php8.1-fpm start && nginx -g 'daemon off;'"]
CMD ["apache2ctl", "-D", "FOREGROUND"]
