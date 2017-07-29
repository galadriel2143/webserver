#! /bin/bash
CURDIR="$(dirname "$(readlink -e "$0")")"
SECRETS_BASE="/home/secrets"

DOMAIN_NAME="msgor.com"

echo "\"DOMAIN_NAME=$DOMAIN_NAME\"" >> /etc/environment
export DOMAIN_NAME

read -p "Type YES (in caps) if you're sure you want to continue. " CONFIRM

if ! [ "$CONFIRM" == "YES" ] ; then
    echo "Aborting"
    exit 1
fi

if [ "$1" == "everything" ] ; then
    service docker-compose stop
    service dockermailer stop
    docker-compose -f "$CURDIR/www/docker-compose.yml" rm
    docker-compose -f "$CURDIR/www/docker-compose.yml" build
    rm -r /home/secrets
    rm /home/mail/etc/postfix-accounts.cf
    rm /home/ownclouddata/version.php
fi

read -s -p "Enter Duo IKEY: " DUO_IKEY
read -s -p "Enter Duo SKEY: " DUO_SKEY
read -s -p "Enter Duo HOST: " DUO_HOST

DUO_AKEY="$(python -c 'import os, hashlib ; print hashlib.sha1(os.urandom(32)).hexdigest() ; ')"

cat <<INI > "/etc/security/pam_duo.conf"
[duo]
; Duo API host
host = $DUO_HOST

; Duo integration key
ikey = $DUO_IKEY
; Duo secret key 
skey = $DUO_SKEY
INI

read -s -p "Enter Linode API Token: " LINODE_API_TOKEN

rsync -rav "$CURDIR/etc/." "/etc/."

# Install
apt-get install -y --no-install-recommends curl python-software-properties python3-software-properties software-properties-common && \
    curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add - && \
    apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D && \
    add-apt-repository "deb http://apt.linode.com/ $(lsb_release -cs) main" && \
    wget -O- https://apt.linode.com/linode.gpg | sudo apt-key add - && \
    add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main" && \
    curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash - && \
    apt-get remove -y nodejs npm 'vim.*' && \
    apt-get update && \
    apt-get install -y linode-cli w3m unattended-upgrades gdebi-core virtualenv python-virtualenv python-pip checkinstall dos2unix cadaver nmap graphviz expect supervisor vim-nox-py2 tmux htop mysql-client postgresql-client git nodejs docker-engine linux-image-extra-virtual linux-image-extra-$(uname -r) apt-transport-https ca-certificates pwgen build-essential ssl-cert ipcalc libpam-duo acl jq imagemagick || exit 1

#Systempony
gdebi -n "$CURDIR/systempony.deb"

curl -L https://github.com/docker/compose/releases/download/1.10.0/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose && \
    chmod a+x /usr/bin/docker-compose

#Configure
ADDUSER=widget
adduser $ADDUSER 
usermod -a -G docker $ADDUSER && \
    usermod -a -G docker $USER && \
    usermod -a -G sudo $ADDUSER || exit 1

mkdir "$SECRETS_BASE"

# More duo setup
PAM_SSHD="/etc/pam.d/sshd"

if ! grep pam_duo.so "$PAM_SSHD" > /dev/null ; then 
    sed -i '1s/^/auth required pam_duo.so/' "$PAM_SSHD"
fi

SSHD_CONFIG="/etc/ssh/sshd_config"

sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' "$SSHD_CONFIG"

service ssh restart

#MySQL
MYSQL_ROOT_PASSWORD="$(pwgen -s 32)"

# Don't write this more than once because we'll lock ourselves out.
MYSQL_ENV="$SECRETS_BASE/mysql.env"
if [ ! -e "$MYSQL_ENV" ] ; then
    cat <<ENV > "$MYSQL_ENV"
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
ENV
fi

MYSQL_WORDPRESS_PASSWORD="$(pwgen -s 32)"
WORDPRESS_AUTH_KEY="$(pwgen -s 32 | sha1sum)"
WORDPRESS_AUTH_SALT="$(pwgen -s 32 | sha1sum)"
WORDPRESS_SECURE_AUTH_KEY="$(pwgen -s 32 | sha1sum)"
WORDPRESS_SECURE_AUTH_SALT="$(pwgen -s 32 | sha1sum)"
WORDPRESS_LOGGED_IN_KEY="$(pwgen -s 32 | sha1sum)"
WORDPRESS_NONCE_KEY="$(pwgen -s 32 | sha1sum)"
WORDPRESS_NONCE_SALT="$(pwgen -s 32 | sha1sum)"
WORDPRESS_LOGGED_IN_SALT="$(pwgen -s 32 | sha1sum)"

WORDPRESS_ENV="$SECRETS_BASE/wordpress.env"
if [ ! -e "$WORDPRESS_ENV" ] ; then
    cat <<ENV > "$WORDPRESS_ENV"
WORDPRESS_DB_USER=wordpress
WORDPRESS_DB_PASSWORD=$MYSQL_WORDPRESS_PASSWORD
WORDPRESS_DB_NAME=wordpress
WORDPRESS_TABLE_PREFIX=

WORDPRESS_AUTH_KEY=$WORDPRESS_AUTH_KEY
WORDPRESS_AUTH_SALT=$WORDPRESS_AUTH_SALT
WORDPRESS_SECURE_AUTH_KEY=$WORDPRESS_SECURE_AUTH_KEY
WORDPRESS_SECURE_AUTH_SALT=$WORDPRESS_AUTH_SALT
WORDPRESS_LOGGED_IN_KEY=$WORDPRESS_LOGGED_IN_KEY
WORDPRESS_NONCE_KEY=$WORDPRESS_NONCE_KEY
WORDPRESS_NONCE_SALT=$WORDPRESS_NONCE_SALT
WORDPRESS_LOGGED_IN_SALT=$WORDPRESS_LOGGED_IN_SALT
ENV
fi

MYSQL_OWNCLOUD_PASSWORD="$(pwgen -s 32)"
OWNCLOUD_ADMIN_PASS="$(pwgen -s 32)"

OWNCLOUD_ENV="$SECRETS_BASE/owncloud.env"
if [ ! -e "$OWNCLOUD_ENV" ] ; then
    cat <<ENV > "$OWNCLOUD_ENV"
DB_TYPE=mysql
DB_HOST=mysql
DB_NAME=owncloud
DB_USER=owncloud
DB_PASS=$MYSQL_OWNCLOUD_PASSWORD
DB_TABLE_PREFIX=
TRUSTED_DOMAINS=localhost cloud.$DOMAIN_NAME
ADMIN_USER=widget
ADMIN_PASS=$OWNCLOUD_ADMIN_PASS
TIMEZONE=America/New_York
DUO_IKEY=$DUO_IKEY
DUO_SKEY=$DUO_SKEY
DUO_HOST=$DUO_HOST
DUO_AKEY=$DUO_AKEY
ENV
fi

cat <<ENV > "$SECRETS_BASE/fpm.env"
LINODE_API_TOKEN=$LINODE_API_TOKEN
ENV

cat <<ENV > "$SECRETS_BASE/nginx.env"
ENV

PSQL_PASSWORD="$(pwgen -s 32)"

PSQL_ENV="$SECRETS_BASE/psql.env"
if [ ! -e "$PSQL_ENV" ] ; then
    cat <<ENV > "$PSQL_ENV"
POSTGRES_PASSWORD=$PSQL_PASSWORD
ENV
fi

PSQL_AGENDAV_PASSWORD="$(pwgen -s 32)"
AGENDAV_ENC_KEY="$(pwgen -s 32)"

AGENDAV_ENV="$SECRETS_BASE/agendav.env"
if [ ! -e "$AGENDAV_ENV" ] ; then
    cat <<ENV > "$AGENDAV_ENV"
AGENDAV_TITLE=$DOMAIN_NAME
AGENDAV_FOOTER=$DOMAIN_NAME
AGENDAV_DB_NAME=agendav
AGENDAV_DB_USER=agendav
AGENDAV_DB_PASSWORD=$PSQL_AGENDAV_PASSWORD
AGENDAV_ENC_KEY=$AGENDAV_ENC_KEY
AGENDAV_CALDAV_BASEURL_PUBLIC=https://dav.$DOMAIN_NAME:443/dav.php
AGENDAV_CALDAV_BASEURL=https://dav.$DOMAIN_NAME:443/dav.php
AGENDAV_TIMEZONE=America/New_York
AGENDAV_LANG=en
ENV
fi

MYSQL_BAIKAL_PASSWORD="$(pwgen -s 32)"
BAIKAL_ADMIN_PASSWORD="$(pwgen -s 32)"

BAIKAL_ENV="$SECRETS_BASE/baikal.env"
if [ ! -e "$BAIKAL_ENV" ] ; then
    cat <<ENV > "$BAIKAL_ENV"
CONTAINER_DOMAIN_NAME=dav.$DOMAIN_NAME
BAIKAL_DB_HOST=mysql
BAIKAL_DB_NAME=baikal
BAIKAL_DB_USER=baikal
BAIKAL_DB_PASSWORD=$MYSQL_BAIKAL_PASSWORD
BAIKAL_ADMIN_PASSWORD=$BAIKAL_ADMIN_PASSWORD
BAIKAL_DAV_AUTH_TYPE=Basic
BAIKAL_TIMEZONE=America/New_York
ENV
fi

MYSQL_ROUNDCUBE_PASSWORD="$(pwgen -s 32)"
ROUNDCUBE_24CHR_DES_KEY="$(pwgen -s 24)"

ROUNDCUBE_ENV="$SECRETS_BASE/roundcube.env"
if [ ! -e "$ROUNDCUBE_ENV" ] ; then
    cat <<ENV > "$ROUNDCUBE_ENV"
ROUNDCUBE_DB_TYPE=mysql
ROUNDCUBE_DB_USER=roundcube
ROUNDCUBE_DB_PASSWORD=$MYSQL_ROUNDCUBE_PASSWORD
ROUNDCUBE_DB_HOST=mysql
ROUNDCUBE_DB_NAME=roundcube

ROUNDCUBE_24CHR_DES_KEY=$ROUNDCUBE_24CHR_DES_KEY
ROUNDCUBE_USERNAME_DOMAIN=$DOMAIN_NAME
ROUNDCUBE_HTMLEDITOR=4
ROUNDCUBE_PRODUCT_NAME=$DOMAIN_NAME Mail
ROUNDCUBE_DRAFT_AUTOSAVE=180
ROUNDCUBE_PREVIEW_PANE=true

ROUNDCUBE_IMAP_HOST=ssl://mail.$DOMAIN_NAME
ROUNDCUBE_SMTP_HOST=tls://mail.$DOMAIN_NAME
ROUNDCUBE_IMAP_CACHE=db
ROUNDCUBE_MESSAGES_CACHE=db
ROUNDCUBE_IMAP_CACHE_TTL=10d
ROUNDCUBE_MESSAGES_CACHE_TTL=10d
ROUNDCUBE_MESSAGES_CACHE_THRESHOLD=50
ROUNDCUBE_SESSION_STORAGE=db
ROUNDCUBE_MEMCACHE_HOSTS=["memcache:11211"]
ROUNDCUBE_SENDMAIL_DELAY=5
ROUNDCUBE_MAX_RECIPIENTS=100
ROUNDCUBE_EMAIL_DNS_CHECK=true
ROUNDCUBE_PLUGINS=["managesieve", "vcard_attachments", "emoticons", "carddav", "duo_auth"]

MANAGESIEVE_HOST=mail.$DOMAIN_NAME
MANAGESIEVE_USETLS=true

CARDDAV_ADDRESSBOOK_PRESET={"name":"dav.$DOMAIN_NAME","username":"%u","password":"%p","url":"https://dav.$DOMAIN_NAME/dav.php/addressbooks/%u/default","active":true,"readonly":false,"refresh_time":"00:05:00", "fixed":["refresh_time", "name", "username", "password", "url", "hide"], "hide": true}

DUO_AUTH_HOST=$DUO_HOST
DUO_AUTH_IKEY=$DUO_IKEY
DUO_AUTH_SKEY=$DUO_SKEY
DUO_AUTH_AKEY=$DUO_AKEY
ENV
fi

cat <<ENV > "$SECRETS_BASE/memcached.env"
ENV

systemctl daemon-reload
service docker-compose restart

"$CURDIR/letsencrypt.sh"

CREATES="wordpress:$MYSQL_WORDPRESS_PASSWORD roundcube:$MYSQL_ROUNDCUBE_PASSWORD owncloud:$MYSQL_OWNCLOUD_PASSWORD baikal:$MYSQL_BAIKAL_PASSWORD"
for create in $CREATES ; do
    cuser="$(echo "$create" | awk '-F:' '{print $1}')"
    cpassword="$(echo "$create" | awk '-F:' '{print $2}')"

    until cat <<SQL | mysql --protocol tcp -u root "-p$MYSQL_ROOT_PASSWORD"
    CREATE USER IF NOT EXISTS '$cuser'@'172.%.%.%'
        IDENTIFIED BY '$cpassword';

    CREATE DATABASE IF NOT EXISTS $cuser;

    GRANT ALL ON $cuser.* to '$cuser'@'172.%.%.%';
SQL
    do
        echo "Waiting for MySQL..."
        sleep 1
    done
done

until cat <<SQL | PGPASSWORD="$PSQL_PASSWORD" psql -h localhost -p 5432 postgres postgres
CREATE USER agendav WITH PASSWORD '$PSQL_AGENDAV_PASSWORD';
CREATE DATABASE agendav ENCODING 'UTF8';
GRANT ALL PRIVILEGES ON DATABASE agendav to agendav;
\q
SQL
do 
    echo "Waiting for Postgres..."
    sleep 1
done

#Setup mail-related thingies.
"$CURDIR/provision_mail.sh"

#Setup initial user folder with dotfiles, other config.
sudo -u $ADDUSER -i bash "$CURDIR/setupwidget.sh"

#Secure all the shit
chmod go-rwx -R "$SECRETS_BASE"
