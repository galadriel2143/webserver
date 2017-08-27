#! /bin/sh
CURDIR="$(dirname "$(readlink -f "$0")")"
PATH="$PATH:$CURDIR/node_modules/.bin"
export PATH

until mysql -h "$BAIKAL_DB_HOST" -u "$BAIKAL_DB_USER" "-p$BAIKAL_DB_PASSWORD" -D "$BAIKAL_DB_NAME" -e "SELECT 1;" ; do
    echo "Waiting for database..."
    sleep 1
done

if [ "$1" = "addusers" ] ; then
    for user in "${@:2}" ; do
        casperjs "$CURDIR/addusers.js" "--container-domain-name=$CONTAINER_DOMAIN_NAME" "--admin-password=$BAIKAL_ADMIN_PASSWORD" "--admin-username=admin" "$user"
    done
else
    casperjs "$CURDIR/casper.js" "--timezone=$BAIKAL_TIMEZONE" "--dav-auth-type=$BAIKAL_DAV_AUTH_TYPE" "--admin-password=$BAIKAL_ADMIN_PASSWORD" "--db-host=$BAIKAL_DB_HOST" "--db-user=$BAIKAL_DB_USER" "--db-name=$BAIKAL_DB_NAME" "--db-password=$BAIKAL_DB_PASSWORD" "--container-domain-name=$CONTAINER_DOMAIN_NAME"
fi
