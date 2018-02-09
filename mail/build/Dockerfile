FROM tvial/docker-mailserver:2.3

COPY entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

RUN apt-get update && \
    apt-get install --no-install-recommends -y dovecot-solr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^#mail_plugins =/mail_plugins = $mail_plugins fts fts_solr/g' /etc/dovecot/conf.d/10-mail.conf

COPY 90-solr.conf /etc/dovecot/conf.d/90-solr.conf

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/start-mailserver.sh"]
