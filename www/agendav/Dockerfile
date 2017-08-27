# agendav
FROM php:7.1-fpm-alpine

MAINTAINER Jan Losinski <losinski@wh2.tu-dresden.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apk add --no-cache \
    postgresql-client \
    wget \
    ca-certificates \
    libpq \
    postgresql-dev \
    libmcrypt-dev \
    libmcrypt \
    curl \
    curl-dev

RUN docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) pdo_pgsql mcrypt curl opcache

#COPY phpinfo.php /var/www/agendav/web/public/phpinfo.php

COPY log_errors.conf /usr/local/etc/php-fpm.d/log_errors.conf

RUN cd /var/www && \
    mkdir -p /var/www/agendav && \
    cd agendav && \
    wget -qO- 'https://github.com/agendav/agendav/releases/download/2.0.0/agendav-2.0.0.tar.gz' | \
    tar --strip-components=1 -xzvf - && \
    cd ..

RUN chown -R www-data:www-data /var/www/agendav/web/var

COPY settings.php /var/www

RUN ln -s /var/www/settings.php /var/www/agendav/web/config/settings.php

COPY run /usr/local/bin/run_container

VOLUME ["/var/www/agendav"]

ENTRYPOINT ["/usr/local/bin/run_container"]
CMD ["php-fpm"]
