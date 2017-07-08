# For running the latest ampache directly from the repository

FROM php:7.1-apache

ENV AMPACHE_VER=3.8.2

# Install everything
# For installing ffmpeg, the deb-multimedia repository is used which might be considered unsafe so use with caution
RUN echo deb http://www.deb-multimedia.org jessie main non-free >> /etc/apt/sources.list \
                        && apt-get update && apt-get install -y --force-yes -q deb-multimedia-keyring \
                        && apt-get update && apt-get install -y -q git ffmpeg libgd3 libpng-dev libjpeg-dev libfreetype6-dev \
                        && apt-get clean \
                        && rm -rf /var/lib/apt/lists/* \
                        && docker-php-ext-install pdo_mysql gettext gd

RUN a2enmod rewrite \
                        && cd /var/www   \
                        && git clone 'https://github.com/ampache/ampache.git' \
                        && cd ampache \
                        && git checkout ${AMPACHE_VER} \
                        && cd .. \
                        && mv ampache/* html/ \
                        && rm -r ampache \
                        && rm -rf /tmp/* /var/tmp/*  \
                        && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
                        && cd html \
                        && cp rest/.htaccess.dist rest/.htaccess \
                        && cp play/.htaccess.dist play/.htaccess \
                        && cp channel/.htaccess.dist channel/.htaccess \
                        && composer install --prefer-source --no-interaction \
                        && apt-get remove -y git \
                        && apt-get autoremove -y \
                        && mkdir -p /var/data \
                        && chown -R www-data:www-data /var/www/html

VOLUME ["/var/www/html/config","/var/www/html/themes","/var/data"]

CMD ["apache2-foreground"]
