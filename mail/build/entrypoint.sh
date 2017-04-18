#! /bin/bash
BASE="/tmp/docker-mailserver/"

mkdir -p "$BASE"

ACCOUNTS_FILE="$BASE/postfix-accounts.cf"

# Only copy the passwords once, so if a user wants to change it after setup it isn't persisted unhashed.
if [ ! -e "$ACCOUNTS_FILE" ] ; then
    touch "$ACCOUNTS_FILE"
    for muser in $MAIL_USERS ; do
        MUSERNAME="$(echo $muser | awk '-F:' '{print $1}')"
        MPASSWORD="$(echo $muser | awk '-F:' '{print $2}')"

        echo "$MUSERNAME|$(doveadm pw -s SHA512-CRYPT -u "$MUSERNAME" -p "$MPASSWORD")" >> "$ACCOUNTS_FILE"
    done
fi

ALIAS_FILE="$BASE/postfix-virtual.cf"
touch "$ALIAS_FILE"
truncate --size=0 "$ALIAS_FILE"
for malias in $MAIL_ALIASES ; do
    MALIAS="$(echo $malias | awk '-F:' '{print $1}')"
    MDEST="$(echo $malias | awk '-F:' '{print $2}')"

    echo "$MALIAS, $MDEST" >> "$ALIAS_FILE"
done

postconf -e "message_size_limit = ${ATTACHMENT_SIZE_LIMIT:-10240000}"

exec "$@"
