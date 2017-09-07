#! /bin/sh
CURDIR="$(dirname "$(readlink -f "$0")")"
SECRETS_BASE="/home/secrets"

#read -s -p "Enter Duo IKEY: " DUO_IKEY
#read -s -p "Enter Duo SKEY: " DUO_SKEY
#read -s -p "Enter Duo HOST: " DUO_HOST

# lol not even Python preinstalled
#apk add python

#DUO_AKEY="$(python -c 'import os, hashlib ; print hashlib.sha1(os.urandom(32)).hexdigest() ; ')"

#echo $DUO_AKEY

DOMAIN_NAME="msgor.com"

echo "\"DOMAIN_NAME=$DOMAIN_NAME\"" >> /etc/environment
export DOMAIN_NAME

#read -p "Type YES (in caps) if you're sure you want to continue. " CONFIRM

if ! [ "$CONFIRM" = "YES" ] ; then
    echo "Aborting"
    #exit 1
fi

if [ "$1" = "everything" ] ; then
    "$CURDIR/rebuild.sh"
    rm -rf /home/secrets
    rm -f /home/mail/etc/postfix-accounts.cf
    rm -f /home/ownclouddata/version.php
fi

setup-alpine -q

sed -i 's/^#\(.*\)3\.\([0-9]\)/\13.\2/g' "/etc/apk/repositories"

EDGE=http://dl-2.alpinelinux.org/alpine/edge/main
# Install
apk update && \
	apk add docker sudo shadow neovim git curl py2-pip python3 nodejs-current fail2ban w3m py-virtualenv cadaver nmap graphviz expect supervisor tmux htop mysql-client postgresql-client ca-certificates pwgen ipcalc duo_unix acl jq imagemagick sqlite py-eyed3 rsync alpine-sdk && \
	apk update -X $EDGE && \
        apk add -X $EDGE openssh-server-pam openssh-client openssh-sftp-server && \
	pip3 install linode-cli || exit $?

rc-update add sshd

ln -s /usr/bin/nvim /usr/bin/vim

addgroup sudo

rsync -rav "$CURDIR/etc/." "/etc/."

# APKBUILD
mkdir -p /var/cache/distfiles

# FIXME All? Really?
chmod a+w /var/cache/distfiles


#TODO Automatic updates?

# This should be near the end
adduser -s /bin/bash widget

addgroup widget sudo
addgroup widget abuild
addgroup widget docker

# Container www group
groupadd -g 82 www-data
useradd -d /var/www -s /bin/false -M -g 82 -u 82 www-data

mkdir "$SECRETS_BASE"

chown -R widget:widget "$CURDIR/max-apk"

HOME="/home/widget" su --preserve-environment -c 'abuild-keygen -a -i -n -q' widget
HOME="/home/widget" su --preserve-environment -c "cd '$CURDIR/max-apk/systempony' && abuild -r" widget
HOME="/home/widget" su --preserve-environment -c "cd '$CURDIR/max-apk/duo_unix' && abuild -r" widget

apk add --allow-untrusted "/home/widget/packages/webserver/x86_64/systempony-1.0.2-r7.apk"
apk add --allow-untrusted "/home/widget/packages/webserver/x86_64/duo_unix-1.10.1-r0.apk"
# duo
PAM_SSHD="/etc/pam.d/sshd"

