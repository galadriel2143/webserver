#! /bin/bash
# Assert that all containers are up and running before pruning volumes.
CURDIR="$(dirname "$(readlink -e "$0")")"

DCWWW="docker-compose -f $CURDIR/www/docker-compose.yml"
DCMAIL="docker-compose -f $CURDIR/mail/docker-compose.yml"
DCVPN="docker-compose -f $CURDIR/vpn/docker-compose.yml" 

CONTAINER_IDS="$($DCWWW ps -q ; $DCVPN ps -q ; $DCMAIL ps -q)"
CONTAINER_COUNT="$(docker inspect $CONTAINER_IDS | jq -r '.[].State.Running | select(. == true)' | wc -l)"

echo $CONTAINER_COUNT
if [ "$CONTAINER_COUNT" == 15 ] ; then
    docker volume prune
    docker ps -a -q | xargs docker rm 
    docker images -q | xargs docker rmi
else
    echo "You shouldn't prune volumes if some containers are down. You could lose data!"
fi
