# webserver
Repository for galadriel2143's webserver provisioning scripts, for galadriel2143's personal webserver.

Brief description of files:

* **aliases.sh**: Helpful command line aliases to add to your shell when working with the docker-compose environments in this project.
* **archive.sh**: Tar up all related files.
* **etc**: Etc files which get synced verbatim to /etc
* **ftty.exp**: Trick a command into thinking it has a TTY. Used to force color output with **logcat.sh**
* **letsencrypt**: Script to regenerate certs for all domains listed in nginx config.
* **logcat.sh**: Tails logs from every docker-compose environment.
* **mail**: Docker-compose setup for mail.
* **provision.sh**: Installs all base programs necessary to get all the docker-compose environments running, as well as some utilities, such as systempony.
* **safe-prune.sh**: Does a stupid check to make sure all containers are running (count is hardcoded). If so, prune all dangling dynamic volumes.
* **setupwidget.sh**: Personal setup script to clone dotfiles into newly created user.
* **systempony.deb**: Awesome system status program that outputs colorized MLP character ASCII art. [Source](https://github.com/mbasaglia/ASCII-Pony)
* **vpn**: OpenVPN docker-compose with DNSmasq.
* **www**: All the (mostly PHP-related) services that sit behind Nginx.
