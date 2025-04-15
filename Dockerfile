FROM php:8.3-fpm

ENV PROJECT_ROOT=/var/www

RUN apt-get update && apt-get -y upgrade && apt-get install --no-install-recommends -y  \
    nginx \
    supervisor \
    git \
    nano \
    unzip \
    wget \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libzip-dev \
    libfreetype6-dev \
    libgd3 \
    libgd-dev

RUN docker-php-ext-configure intl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-configure zip && \
    docker-php-ext-install -j$(nproc) gd intl opcache pcntl pdo_mysql zip

# Copy entrypoint.sh
COPY ./docker/entrypoint.sh /entrypoint.sh

# Copy additional config files
COPY ./docker/etc/nginx/nginx.conf /etc/nginx/
COPY ./docker/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/
COPY ./docker/etc/php/conf.d/php.ini /usr/local/etc/php/
COPY ./docker/etc/php/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/

# Install Composer v2
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

USER www-data
WORKDIR $PROJECT_ROOT

# Expose the port nginx is reachable on
EXPOSE 80

# Let supervisord start nginx & php-fpm
ENTRYPOINT ["/entrypoint.sh"]

USER root

# Configure a healthcheck to validate that everything is up&running
#HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping
