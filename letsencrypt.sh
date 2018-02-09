#! /bin/bash
CURDIR="$(dirname "$(readlink -e "$0")")"
BASE="/home/letsencrypt/etc"

# TODO functions instead of aliases?
shopt -s expand_aliases

. "$CURDIR/aliases.sh"

LINODE_API_TOKEN="$(sudo cat /home/secrets/fpm.env | grep LINODE_API_TOKEN | awk -F= '{ print $2 }')"

for each in $(dcwww run --rm nginx nginx -T | grep -o -P 'ssl_certificate_key.*?;' | tr '#' ' ' | awk '{print $2}' | awk '-F/' '{print $(NF-1)}') mail ; do
    FOLDERNAME="$each"
    SUBDOMAIN="$each.$DOMAIN_NAME"
    if [ "$each" == "www" ] ; then
        SUBDOMAIN="$DOMAIN_NAME"
    fi

    HASDOMAIN="$(linode-domain -a record-list --api-key "$LINODE_API_TOKEN" -l "$DOMAIN_NAME" -t A -j | jq -r '."msgor.com".records[] | select(.name == "'"$each"'")' | wc -l)"
    if [ "$HASDOMAIN" == "0" ] ; then
        echo "Creating domain $SUBDOMAIN"
        linode-domain --api-key "$LINODE_API_TOKEN" -a record-create -l "$DOMAIN_NAME" -n "$each" -t A -R '[remote_addr]' || exit 1
        # Wait some seconds
        sleep 60
    fi

    dcwww run --rm certbot \
        certonly --standalone \
        --preferred-challenges http \
        --domain=$SUBDOMAIN \
        --email=webmaster@$DOMAIN_NAME
    LNPATH="$BASE/live/$FOLDERNAME"
    rm "$LNPATH" ; ln -s "$SUBDOMAIN" "$LNPATH"
done

#Reload Nginx config after updating certs.
nghup
