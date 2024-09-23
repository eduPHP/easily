FROM php:8.1-fpm

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN groupadd -g ${GID} --system laravel
RUN useradd -g laravel --r -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 20M/g" /usr/local/etc/php/php.ini-development
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git \
    unzip \
    zlib1g-dev \
    librabbitmq-dev \
    libpq-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libfreetype-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    supervisor
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts

RUN docker-php-ext-configure intl
RUN docker-php-ext-install mbstring && \
 docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
 docker-php-ext-install gd && \
 docker-php-ext-install pcntl && \
 docker-php-ext-install opcache && \
 docker-php-ext-install pdo && \
 docker-php-ext-install pdo_mysql && \
 docker-php-ext-install redis && \
 docker-php-ext-install intl && \
 docker-php-ext-install zip && \
 docker-php-ext-install bcmath && \
 docker-php-ext-enable intl

USER laravel

EXPOSE 9000

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
