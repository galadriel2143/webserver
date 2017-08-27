#! /bin/bash
CURDIR="$(dirname "$(readlink -e "$0")")"

shopt -s expand_aliases

. "$CURDIR/aliases.sh"

dcwww exec --user www-data owncloud php /var/www/html/cron.php
