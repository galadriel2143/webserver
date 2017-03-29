# agendav
FROM php:7.1-fpm

MAINTAINER Jan Losinski <losinski@wh2.tu-dresden.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update 

RUN apt-get install -y --no-install-recommends libpq-dev libmcrypt-dev libcurl4-openssl-dev postgresql-client

RUN docker-php-ext-install -j$(nproc) pdo_pgsql mcrypt curl

RUN apt-get clean

#COPY phpinfo.php /var/www/agendav/web/public/phpinfo.php

COPY log_errors.conf /usr/local/etc/php-fpm.d/log_errors.conf

RUN cd /var/www && \
	apt-get -y install --no-install-recommends wget ca-certificates && \
    wget -O /tmp/agendav.tar.gz https://github.com/agendav/agendav/releases/download/2.0.0/agendav-2.0.0.tar.gz && \
    mkdir -p /var/www/agendav && \
    cd agendav && \
    tar --strip-components=1 -x -v -f /tmp/agendav.tar.gz && \
    cd .. && \
	apt-get clean

RUN chown -R www-data:www-data /var/www/agendav/web/var

COPY settings.php /var/www

RUN ln -s /var/www/settings.php /var/www/agendav/web/config/settings.php

COPY run /usr/local/bin/run_container

VOLUME ["/var/www/agendav"]

ENTRYPOINT ["/usr/local/bin/run_container"]
CMD ["php-fpm"]
