FROM php:8.1-fpm-alpine

ARG UID=1000
ARG GID=1000

RUN addgroup -g "${GID}" --system laravel || true \
    && adduser -G laravel --system -D -s /bin/sh -u "${UID}" laravel || true \
    && apk add --no-cache bash git curl icu-dev libzip-dev oniguruma-dev \
    && docker-php-ext-install pdo pdo_mysql mysqli intl zip opcache

WORKDIR /var/www/html
USER laravel
