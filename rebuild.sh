#! /bin/bash
CURDIR="$(dirname "$(readlink -e "$0")")"

for each in dockervpn dockermailer shipyard docker-compose ; do
    if ! service $each stop ; then
        echo "Service $each not successfully stopped."
    fi
done

for each in www mail vpn shipyard ; do
    DOCKER_COMPOSE="docker-compose -f $CURDIR/$each/docker-compose.yml" 
    $DOCKER_COMPOSE rm
    $DOCKER_COMPOSE build
done
