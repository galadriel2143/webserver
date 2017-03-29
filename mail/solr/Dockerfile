FROM solr:6.4

USER $SOLR_USER

RUN bin/solr start && bin/solr create -c dovecot -n dovecot && bin/solr stop

COPY ./dovecot /opt/solr/server/solr/dovecot

USER root

RUN chown solr:solr /opt/solr/server/solr/dovecot

RUN rm /opt/solr/server/solr/dovecot/conf/managed-schema

USER $SOLR_USER
