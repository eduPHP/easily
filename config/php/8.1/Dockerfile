FROM php:8.1-fpm-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /app

WORKDIR /app

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system laravel && \
    adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf && \
    cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini  && \
    sed -i "s/memory_limit = 128M/memory_limit = 512M/g" /usr/local/etc/php/php.ini && \
    sed -i "s/listen = 127.0.0.1:9000/listen = 127.0.0.1:9081/g" /usr/local/etc/php-fpm.d/www.conf && \
    echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN apk add --no-cache libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev libzip-dev && \
            docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
            docker-php-ext-install gd && \
            docker-php-ext-configure pcntl --enable-pcntl && \
            docker-php-ext-install pcntl && \
            docker-php-ext-install pdo pdo_mysql zip

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

USER laravel

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
