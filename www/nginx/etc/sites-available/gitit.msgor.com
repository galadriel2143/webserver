server {
        listen   443;## listen for ipv4; this line is default and implied
        # listen   [::]:443 default_server ipv6only=on; ## listen for ipv6
	keepalive_timeout 70;
    include php.full.conf;
    include deny.conf;

	ssl on;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_ciphers   "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
	ssl_certificate     /home/cert/cert.pem;
	ssl_certificate_key /home/cert/cert.key;
	ssl_session_cache   shared:SSL:10m;
	ssl_session_timeout 10m;

    root /var/www;
    index index.php index.html index.htm;
    try_files $uri $uri/ =404;

    server_name gitit.msgor.com;

    location / {
        proxy_pass http://localhost:6090/;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

}
