#! /bin/sh
CURDIR="$(dirname "$(readlink -f "$0")")"

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

setup-alpine

setup-apkrepos -f

sed -i 's/^#\(.*\)3\.\([0-9]\)/\13.\2/g' "/etc/apk/repositories"

# Install
apk update && \
	apk add docker sudo shadow neovim git curl py2-pip python3 nodejs-current fail2ban w3m py-virtualenv cadaver nmap graphviz expect supervisor tmux htop mysql-client postgresql-client ca-certificates pwgen ipcalc duo_unix acl jq imagemagick sqlite3 py-eyed3 rsync alpine-sdk && \
	pip3 install linode-cli || exit $?

addgroup sudo

rsync -rav "$CURDIR/etc/." "/etc/."

# APKBUILD
mkdir -p /var/cache/distfiles

# FIXME All? Really?
chmod a+w /var/cache/distfiles

abuild-keygen -a -i

#TODO Automatic updates?

# This should be near the end
adduser widget

addgroup widget sudo
addgroup widget abuild
