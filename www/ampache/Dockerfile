# For running the latest ampache directly from the repository

FROM php:7.1-fpm-alpine

ENV AMPACHE_VER=3.8.2

RUN apk add --no-cache ffmpeg gd freetype jpeg libpng gettext

RUN apk add --no-cache --virtual .ampache-ext-deps gettext-dev gd-dev libpng-dev jpeg-dev freetype-dev \
    && docker-php-ext-install pdo_mysql gettext gd opcache \
    && apk del .ampache-ext-deps

RUN cd /var/www \
    && apk add --no-cache git \
    && git clone 'https://github.com/ampache/ampache.git' html \
    && cd html \
    && git checkout ${AMPACHE_VER} \
    && cd .. \
    && mkdir ampache \
    && mv html/* ampache/ \
    && rm -rf html \
    && rm -rf /tmp/* /var/tmp/*  \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && cd ampache \
    && cp rest/.htaccess.dist rest/.htaccess \
    && cp play/.htaccess.dist play/.htaccess \
    && cp channel/.htaccess.dist channel/.htaccess \
    && composer install --no-dev --prefer-dist --no-interaction \
    && apk del git \
    && mkdir -p /var/lib/ampache/data \
    && mv /var/www/ampache/config /var/www/ampache/themes /var/lib/ampache \
    && ln -s /var/lib/ampache/config /var/www/ampache/config \
    && ln -s /var/lib/ampache/themes /var/www/ampache/themes \
    && ln -s /var/lib/ampache/data /var/data \
    && chown -R www-data:www-data /var/www/ampache

VOLUME ["/var/lib/ampache/config","/var/lib/ampache/themes","/var/lib/ampache/data", "/var/www/ampache"]

CMD ["php-fpm"]
