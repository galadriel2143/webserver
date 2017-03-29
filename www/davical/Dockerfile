# davical
FROM php:5-fpm

MAINTAINER Jan Losinski <losinski@wh2.tu-dresden.de>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update 

RUN apt-get -y install --no-install-recommends davical libcurl4-openssl-dev libpq-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN docker-php-ext-install -j$(nproc) curl pdo_pgsql

COPY davical.conf /etc/apache2/sites-available/davical.conf
COPY example-config.php /etc/davical/config_real.php
COPY run /usr/local/bin/run_container

RUN ln -sf /dev/stderr /var/log/apache2/davi-error.log

VOLUME [ "/etc/davical", "/usr/share/davical" ]

EXPOSE 80 

ENTRYPOINT ["/usr/local/bin/run_container"]
CMD ["php-fpm"]
