FROM php:5.6-fpm

RUN apt-get update && apt-get install --no-install-recommends -y \
	unzip \
	libcurl4-openssl-dev \
	libfreetype6-dev \
	libicu-dev \
	libjpeg-dev \
	libldap2-dev \
	libmcrypt-dev \
	libmemcached-dev \
	libpng12-dev \
	libpq-dev \
	libxml2-dev \
    mysql-client \
	&& rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# https://doc.owncloud.org/server/8.1/admin_manual/installation/source_installation.html#prerequisites
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
	&& docker-php-ext-install -j$(nproc) exif gd intl ldap mbstring mcrypt mysql opcache pdo_mysql pdo_pgsql pgsql zip

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# PECL extensions
RUN set -ex \
	&& pecl install APCu-4.0.10 \
	&& pecl install memcached-2.2.0 \
	&& pecl install redis-2.2.8 \
	&& docker-php-ext-enable apcu memcached redis

VOLUME /var/www/html

COPY src /usr/src/owncloud

RUN curl -fsSL -o /tmp/duo.zip https://github.com/elie195/duo_provider/archive/6fc69632d97dc9fcc039e6dd1f61fc1da8b50463.zip

RUN unzip /tmp/duo.zip -d /usr/src/owncloud/apps

RUN mv /usr/src/owncloud/apps/duo* /usr/src/owncloud/apps/duo

COPY duo.ini /etc/duo.ini

RUN ln -s /etc/duo.ini /usr/src/owncloud/apps/duo/duo.ini && \
    chown www-data:www-data /etc/duo.ini && \
    chmod 600 /etc/duo.ini

COPY entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
