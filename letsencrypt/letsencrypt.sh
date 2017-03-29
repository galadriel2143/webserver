#! /bin/bash
BASE="/home/letsencrypt/etc"
WEBROOT="/var/www/letsencrypt"
for each in $(cat /home/docker/www/nginx/etc/sites-enabled/default | grep -o -P 'ssl_certificate_key.*?;' | tr '#' ' ' | awk '{print $2}' | awk '-F/' '{print $(NF-1)}') mail ; do
    FOLDERNAME="$each"
    SUBDOMAIN="$each.$DOMAIN_NAME"
    if [ "$each" == "www" ] ; then
        SUBDOMAIN="$DOMAIN_NAME"
    fi
    docker run --rm -it --name letsencrypt \
        -v "$BASE:/etc/letsencrypt" \
        -v "$WEBROOT:$WEBROOT" \
        quay.io/letsencrypt/letsencrypt:latest \
        auth --authenticator webroot \
        --webroot-path "$WEBROOT" \
        --domain=$SUBDOMAIN \
        --email=webmaster@msgor.com
    LNPATH="$BASE/live/$FOLDERNAME"
    rm "$LNPATH" ; ln -s "$SUBDOMAIN" "$LNPATH"
done
