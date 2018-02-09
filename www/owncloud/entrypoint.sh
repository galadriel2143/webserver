#! /bin/sh
set -e

if [ ! -e '/var/www/html/version.php' ]; then
    tar cf - --one-file-system -C /usr/src/owncloud . | tar xf -
    chown -R www-data /var/www/html
fi

until mysql -h "$DB_HOST" -u "$DB_USER" "-p$DB_PASS" -D "$DB_NAME" -e "SELECT 1;" ; do
    echo "Waiting for MySQL..."
    sleep 1
done

CONFIG_FILE="/etc/duo.ini"

sed -i -e "s/DUO_IKEY/$( echo "${DUO_IKEY}" | sed -e 's/[\/}]/\\&/g')/" ${CONFIG_FILE}
sed -i -e "s/DUO_SKEY/$( echo "${DUO_SKEY}" | sed -e 's/[\/}]/\\&/g')/" ${CONFIG_FILE}
sed -i -e "s/DUO_HOST/$( echo "${DUO_HOST}" | sed -e 's/[\/}]/\\&/g')/" ${CONFIG_FILE}
sed -i -e "s/DUO_AKEY/$( echo "${DUO_AKEY}" | sed -e 's/[\/}]/\\&/g')/" ${CONFIG_FILE}

SU="su -s /bin/sh -c"

$SU "php /var/www/html/occ maintenance:install --database-host $DB_HOST --database-name $DB_NAME --database-user $DB_USER --database-pass $DB_PASS --admin-user $ADMIN_USER --admin-pass $ADMIN_PASS" www-data || echo "Install already executed!"

if [ ! -z "$DUO_IKEY" ] && [ ! -z "$DUO_HOST" ] && [ ! -z "$DUO_AKEY" ] && [ ! -z "$DUO_SKEY" ] ; then
    $SU "php /var/www/html/occ app:enable duo" www-data && echo "Duo enabled"
else
    $SU "php /var/www/html/occ app:disable duo" www-data && echo "Duo disabled"
fi

$SU "php /var/www/html/occ config:system:set trusted_domains" www-data
TRUST_COUNT=0
for domain in $TRUSTED_DOMAINS ; do
    $SU "php /var/www/html/occ config:system:set trusted_domains $TRUST_COUNT --value=$domain" www-data
    TRUST_COUNT=$((TRUST_COUNT+1))
done

exec "$@"
