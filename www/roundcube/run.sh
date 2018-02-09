#!/bin/sh

chown www-data:www-data /var/www -R

until mysql -h "$ROUNDCUBE_DB_HOST" -u "$ROUNDCUBE_DB_USER" -p"$ROUNDCUBE_DB_PASSWORD" -D "$ROUNDCUBE_DB_NAME" -e "SELECT 1;" ; do
    echo "Waiting for MySQL..."
    sleep 1
done

/var/www/roundcube/bin/initdb.sh --dir /var/www/roundcube/SQL

exec "$@"
