server {
    listen   80; ## listen for ipv4; this line is default and implied
    # listen   [::]:80 default_server ipv6only=on; ## listen for ipv6

    root /var/www;

    location /redirtest/ {
        break;
    }

    location /3ds {
    }

    location / {
        return 301 https://$host$request_uri;
    }

}
