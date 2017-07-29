FROM php:7.1-fpm

MAINTAINER Claudio Ferreira <filhocf@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ARG RC_VERSION=1.3-beta

RUN mkdir -p /var/www/roundcube && chown -R www-data:www-data /var/www/roundcube

RUN apt-get update \
    && apt-get install -y --no-install-recommends git libz-dev libmemcached-dev mysql-client unzip "libldap-.*" libpng-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install memcached

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install -j$(nproc) pdo_mysql gd ldap

# Get Roundcube package
USER www-data
WORKDIR /var/www/roundcube
# RUN curl -L https://github.com/djenniex/phpMemcachedAdmin/archive/master.tar.gz | tar xz --strip-components=1
RUN \
    curl -L https://github.com/roundcube/roundcubemail/releases/download/$RC_VERSION/roundcubemail-$RC_VERSION-complete.tar.gz | \
    tar xz --strip-components=1 && \
    # Get plugins
    # Attention: need to create the final directory before donwload and extract the respective plugin
      mkdir plugins/duo_auth plugins/contextmenu plugins/contextmenu_folder plugins/message_highlight plugins/infinitescroll \
        plugins/thunderbird_labels plugins/removeattachments plugins/attachment_position skins/melanie2_larry_mobile \
        plugins/mobile plugins/jquery_mobile skins/mabola-blue skins/mabola skins/chameleon && \
    # Download and install each plugin/skin
      curl -L https://github.com/tweakier/duo_auth/archive/c3acfaca61c34fed73e140678227461e854ffe15.tar.gz | \
      tar xz --strip-components=1 -C plugins/duo_auth && \
      curl -L https://github.com/JohnDoh/Roundcube-Plugin-Context-Menu/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/contextmenu && \
      curl -L https://github.com/filhocf/contextmenu_folder/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/contextmenu_folder && \
      curl -L https://github.com/corbosman/message_highlight/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/message_highlight && \
      curl -L https://github.com/messagerie-melanie2/Roundcube-Plugin-Infinite-Scroll/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/infinitescroll && \
      curl -L https://github.com/mike-kfed/rcmail-thunderbird-labels/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/thunderbird_labels && \
      #wget -O- https://github.com/dsoares/Roundcube-Plugin-RemoveAttachments/archive/0.2.3.tar.gz    -O removeattach.tar.gz && \
      curl -L https://github.com/filhocf/Roundcube-Plugin-RemoveAttachments/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/removeattachments && \
      #wget -O- https://github.com/dapphp/Roundcube-Plugin-attachment_position/archive/1.0.0.tar.gz   -O attachposition.tar.gz && \
      curl -L https://github.com/filhocf/Roundcube-Plugin-attachment_position/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/attachment_position && \
      #wget -O- https://github.com/teonsystems/roundcube-plugin-keyboard-shortcuts-ng/archive/v0.9.4.tar.gz -O kbshortcutsng.tar.gz && \
      #wget -O- https://gitlab.awesome-it.de/filhocf/roundcube-plugins/repository/archive.tar.gz?ref=feature_caldav -O kolab.tar.gz && \
      #wget -O- https://github.com/messagerie-melanie2/Roundcube-Plugin-Roundrive/archive/master.tar.gz  -O roundrive.tar.gz && \
      curl -L https://github.com/messagerie-melanie2/Roundcube-Skin-Melanie2-Larry-Mobile/archive/master.tar.gz | \
      tar xz --strip-components=1 -C skins/melanie2_larry_mobile && \
      curl -L https://github.com/messagerie-melanie2/Roundcube-Plugin-Mobile/archive/master.tar.gz  | \
      tar xz --strip-components=1 -C plugins/mobile && \
      curl -L https://github.com/messagerie-melanie2/Roundcube-Plugin-JQuery-Mobile/archive/master.tar.gz | \
      tar xz --strip-components=1 -C plugins/jquery_mobile && \
    # Get themes
      curl -L https://github.com/EstudioNexos/mabola-blue/archive/master.tar.gz | \
      tar xz --strip-components=1 -C skins/mabola-blue && \
      curl -L https://github.com/EstudioNexos/mabola/archive/master.tar.gz | \
      tar xz --strip-components=1 -C skins/mabola && \
      curl -L https://github.com/filhocf/roundcubemail-skin-chameleon/archive/master.tar.gz | \
      tar xz --strip-components=1 -C skins/chameleon

# Fix issue with duo_auth plugin
RUN sed -i 's/get_input_value/rcube_utils::&/g' plugins/duo_auth/duo_auth.php && \
    sed -i 's/RCUBE_INPUT_POST/rcube_utils::INPUT_POST/g' plugins/duo_auth/duo_auth.php

USER www-data
RUN \
    echo "Add Awesome's plugin ===============>>>>>>>>>>>>>" && \
      cd plugins && \
      git clone -v https://gitlab.awesome-it.de/filhocf/roundcube-plugins.git && \
      ln -s roundcube-plugins/plugins/calendar && \
      ln -s roundcube-plugins/plugins/libcalendaring && \
      ln -s roundcube-plugins/plugins/piwik_analytics && \
      ln -s roundcube-plugins/plugins/pdfviewer && \
      ln -s roundcube-plugins/plugins/odfviewer && \
      ln -s roundcube-plugins/plugins/tasklist && \
    chown www-data.www-data /var/www/roundcube -R

# Install the Composer - package manager for PHP
USER root

WORKDIR /usr/local/bin
RUN curl -L https://getcomposer.org/download/1.4.0/composer.phar > /usr/bin/composer && \
    chmod +x /usr/bin/composer && \
    echo 'TLS_REQCERT never' >> /etc/ldap/ldap.conf

USER www-data
WORKDIR /var/www/roundcube

RUN composer require --no-suggest roundcube/carddav:2.* && composer install --no-dev

# Install dependencies for calendar
#USER www-data
#WORKDIR /var/www//plugins/calendar/lib
#RUN \
    #composer -vv remove -n sabre/dav && \
    #composer -vv remove -n fkooman/oauth-client && \
    #composer -vv require -n sabre/dav 1.8.12 && \
    #composer -vv require -n sabre/http && \
    #composer -vv require -n fkooman/oauth-client && \
    #rm -rf `find /var -iname .composer` && \
    #rm -rf `find /var -iname .git`

USER root

RUN apt-get remove -y git && apt-get autoremove -y && apt-get clean

COPY config.inc.php /var/www/roundcube/config/config.inc.php
COPY plugins /var/www/roundcube/plugins
COPY log_errors.conf /usr/local/etc/php-fpm.d/log_errors.conf

RUN ln -s /dev/stdout /var/www/roundcube/logs/errors

COPY run.sh /run.sh
RUN chmod a+x /run.sh

RUN echo "extension = memcached.so" > /usr/local/etc/php/conf.d/memcached.ini

VOLUME /var/www/roundcube

ENTRYPOINT ["/run.sh"]
CMD ["php-fpm"]
