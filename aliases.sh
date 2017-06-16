#! /bin/bash
#FIXME
CURDIR=/home/docker 

# Aliases specific to this setup
alias "dcwww=sudo docker-compose -f $CURDIR/www/docker-compose.yml"
alias "dcvpn=sudo docker-compose -f $CURDIR/vpn/docker-compose.yml"
alias "dcmail=sudo docker-compose -f $CURDIR/mail/docker-compose.yml"
alias "dcship=sudo docker-compose -f $CURDIR/shipyard/docker-compose.yml"

alias "occ=dcwww exec --user www-data owncloud php occ"

alias 'mysqlr=mysql -h 127.0.0.1 -u root "-p$(sudo cat /home/secrets/mysql.env | awk "-F=" "{print \$2}")"'
alias 'psqlr=PGPASSWORD=$(sudo cat /home/secrets/psql.env | awk "-F=" "{print \$2}") psql -h localhost -U postgres'
alias 'vpn-keygen=dcvpn exec vpn easyrsa build-client-full'
alias 'vpn-keyget=dcvpn exec vpn ovpn_getclient'
