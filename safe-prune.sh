#! /bin/bash
# Assert that all containers are up and running before pruning volumes.
CURDIR="$(dirname "$(readlink -f "$0")")"

DCWWW="docker-compose -f $CURDIR/www/docker-compose.yml"
DCMAIL="docker-compose -f $CURDIR/mail/docker-compose.yml"
DCVPN="docker-compose -f $CURDIR/vpn/docker-compose.yml" 
DCSHIP="docker-compose -f $CURDIR/shipyard/docker-compose.yml"

LIST_OTHERS=
KILL_OTHERS=
QUIET=
for i in "$@" ; do
    case "$1" in 
        -lo|--list-others) LIST_OTHERS=1 ;;
        -q|--quiet) QUIET="--quiet" ;;
        -ko|--kill-others) KILL_OTHERS=1 ; QUIET="--quiet" ;;
    esac
    shift
done

CONTAINER_IDS="$($DCWWW ps -q && $DCVPN ps -q && $DCMAIL ps -q && $DCSHIP ps -q )" || exit $?

OTHERS="$(docker ps --no-trunc $QUIET | grep -v "$(echo "$CONTAINER_IDS" | sed -e 's/\s+/\\|/g')")"

if [ ! -z "$LIST_OTHERS" ] ; then
    echo "$OTHERS"
    exit 0
fi

if [ ! -z "$KILL_OTHERS" ] ; then
    echo "$OTHERS" | xargs docker kill
fi

CONTAINER_COUNT="$(docker inspect $CONTAINER_IDS | jq -r '.[].State.Running | select(. == true)' | wc -l)"

docker ps -a -q | xargs docker rm 
docker images -q | xargs docker rmi
echo $CONTAINER_COUNT
if [ "$CONTAINER_COUNT" == 24 ] ; then
    docker volume prune
else
    echo "You shouldn't prune volumes if some containers are down. You could lose data!"
fi
