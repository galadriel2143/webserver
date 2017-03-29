FROM                    php:7.1-fpm
MAINTAINER              pr3d4t0r


LABEL                   author="pr3d4t0r - Eugene Ciurana"
LABEL                   copyright="(c) Copyright 2015, 2016 by CIME Software Ltd."
LABEL                   description="Baikal / SabreDAV robust calendar and address book server with scheduling and email notifications"
LABEL                   license="See: LICENSE.txt for complete licensing information."
LABEL                   support="caldav AT cime.net"
LABEL                   version="2.1"

### "configure-apt"
RUN                     echo "APT::Get::Assume-Yes true;" >> /etc/apt/apt.conf.d/80custom; \
                        echo "APT::Get::Quiet true;" >> /etc/apt/apt.conf.d/80custom; \
                        rm -Rvf /var/lib/apt/lists/*; \
                        apt-get update

### "configure-postfix"
#
# These parameters are specific to your own Postfix relay!  Use your host and domain
# names.
RUN                     echo "postfix postfix/mailname string msgor.com" | debconf-set-selections && \
                        echo "postfix postfix/main_mailer_type string 'Satellite system'" | debconf-set-selections && \
                        echo "postfix postfix/relayhost string msgor.com" | debconf-set-selections && \
                        echo "postfix postfix/root_address string cal-bounce@msgor.com" | debconf-set-selections

### "system-requirements"
RUN                     apt-get install curl libcurl4-openssl-dev postfix mailutils rsyslog unzip libxml2-dev

RUN                     docker-php-ext-install -j$(nproc) pdo_mysql

### "set-locale"
#RUN                     locale-gen en_US.UTF-8 && \
#                        update-locale LANG=en_US.UTF-8 && \
#                        update-locale LANGUAGE=en_US.UTF-8 && \
#                        update-locale LC_ALL=en_US.UTF-8
#
#ENV                     LANG en_US.UTF-8
#ENV                     LANGUAGE en_US:en
#ENV                     LC_ALL en_US.UTF-8
#ENV                     TERM=xterm



### "Baikal-installation"
WORKDIR                 /var/www
RUN                     curl -LO https://github.com/fruux/Baikal/releases/download/0.4.6/baikal-0.4.6.zip && unzip baikal-0.4.6.zip && rm -f baikal-0.4.6.zip
RUN                     mv baikal calendar_server
RUN                     rm -Rvf /var/www/calendar_server/Specific/db/.empty

# Scheduling and email delivery.  See:
# http://sabre.io/dav/scheduling/
# https://groups.google.com/forum/#!searchin/sabredav-discuss/scheduling|sort:relevance/sabredav-discuss/CrGZXqw4sRw/vsHYq6FDcnkJ
# This needs to be patched on the Baikal start up Server.php, NOT in the SabreDAV server.
COPY                    resources/Server.php /var/www/calendar_server/Core/Frameworks/Baikal/Core/Server.php

COPY                    resources/baikal.apache2 /var/www/calendar_server/Specific/virtualhosts/baikal.apache2
COPY                    cal_infox.php /var/www/calendar_server/html/

# The Baikal administration wizard creates these two config files when first run.  Preserve them
# and save them to the resources/ directory.  These files must be preserved for upgrades.
# Both files are already in the .gitignore file.
#
# To use them:  uncomment these two lines and copy them to the Specific/ directory, per the
# Baikal upgrade instructions at:  http://sabre.io/baikal/upgrade/
# COPY                    resources/config.php /var/www/calendar_server/Specific/
# COPY                    resources/config.system.php /var/www/calendar_server/Specific/

WORKDIR                 /var/www/calendar_server

#COPY ./config.system.php Core/Frameworks/Baikal/Model/Config/Database.php

RUN                     chown -Rf www-data:www-data Specific

RUN                     echo "error_log = syslog" >> /usr/local/etc/php/conf.d/error_log.conf

VOLUME                    [ "/var/www/calendar_server" ]

ENTRYPOINT                [ "php-fpm" ]

