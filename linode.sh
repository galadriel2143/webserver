#! /bin/bash
. /home/secrets/fpm.env

function join_by { local IFS="$1"; shift; echo "$*"; }

ARGS="$(join_by '&' "${@:3}")"

JQ="$2"

if [ -z "$JQ" ] ; then
    JQ="."
fi

JQ=("jq" "-r" "$JQ")

JSON="$(curl "https://api.linode.com/?api_key=$LINODE_API_TOKEN&api_action=$1&$ARGS")" 

echo "$JSON" | "${JQ[@]}"
