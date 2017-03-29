#! /bin/bash
CURDIR="$(dirname "$(readlink -e "$0")")"
SECRETS_BASE="/home/secrets"

MAIL_WIDGET_PASSWORD="$(pwgen -s 32)"
MAIL_MONIT_PASSWORD="$(pwgen -s 32)"

#NAGIOS?
#RANCHER-COMPOSE INSTEAD OF DOCKER-COMPOSE?
#RANCHER? COMPLETELY DIFFERENT OS COMPLETELY BASED ON DOCKER. TERRIFYING.

#HOW WILL PASSWORD UPDATES WITH ROUNDCUBE WORK? WILL THEY EVEN WORK?
#WHY AM I TYPING IN ALL CAPS

#THIS ISN'T SECURE. Password shouldn't be stored here UNHASHED.

MAIL_USERS="monit@msgor.com:$MAIL_MONIT_PASSWORD widget@msgor.com:$MAIL_WIDGET_PASSWORD"

MAIL_ENV="$SECRETS_BASE/mail.env"
if [ ! -e "$MAIL_ENV" ] ; then
    cat <<ENV > "$MAIL_ENV"
ENABLE_SPAMASSASSIN=1
ENABLE_CLAMAV=1
ENABLE_FAIL2BAN=1
ENABLE_POSTGREY=1
ENABLE_MANAGESIEVE=1
POSTMASTER_ADDRESS=webmaster@msgor.com
SSL_TYPE=letsencrypt
VIRUSMAILS_DELETE_DELAY=30

ONE_DIR=1
DMS_DEBUG=1
MAIL_USERS=$MAIL_USERS
MAIL_ALIASES=webmaster@msgor.com:widget@msgor.com
ENV
fi

for user in $MAIL_USERS ; do
    docker-compose -f "$CURDIR/www/docker-compose.yml" run baikal_tool addusers "$user"
done

docker-compose -f "$CURDIR/mail/docker-compose.yml" run mail generate-dkim-config

systemctl daemon-reload
service dockermailer restart
