#! /bin/bash
CURDIR="$(dirname "$(readlink -e "$0")")"
/usr/bin/supervisord -c <(
cat <<CONF
[supervisord]
nodaemon=true
logfile=/dev/null

[program:mail]
command="$CURDIR/ftty.exp" /usr/bin/docker-compose -f "$CURDIR/www/docker-compose.yml" logs -f
stderr_logfile=/dev/stderr
stdout_logfile=/dev/stdout
stderr_logfile_maxbytes=0
stdout_logfile_maxbytes=0

[program:www]
command="$CURDIR/ftty.exp" /usr/bin/docker-compose -f "$CURDIR/mail/docker-compose.yml" logs -f
stderr_logfile=/dev/stderr
stdout_logfile=/dev/stdout
stderr_logfile_maxbytes=0
stdout_logfile_maxbytes=0
CONF
)
