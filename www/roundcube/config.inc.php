<?php

$config = array();

# mysql://user:pass@host/db
$config['db_dsnw'] = getenv('ROUNDCUBE_DB_TYPE') . '://' . getenv('ROUNDCUBE_DB_USER') . ':' . getenv('ROUNDCUBE_DB_PASSWORD') . '@' . getenv('ROUNDCUBE_DB_HOST') . '/' . getenv('ROUNDCUBE_DB_NAME');

$config['imap_conn_options'] =
$config['smtp_conn_options'] =
$config['managesieve_conn_options'] = [
    'ssl' => [
        'verify_peer' => false,
        'verify_peer_name' => false,
        'allow_self_signed' => true,
    ],
];

$config['default_host'] = getenv('ROUNDCUBE_IMAP_HOST') ?: 'ssl://localhost';
$config['default_port'] = getenv('ROUNDCUBE_IMAP_PORT') ?: '993';

$config['smtp_server'] = getenv('ROUNDCUBE_SMTP_HOST') ?: 'tls://localhost';
$config['smtp_port'] = intval(getenv('ROUNDCUBE_SMTP_PORT') ?: 587);
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';

$config['des_key'] = getenv('ROUNDCUBE_24CHR_DES_KEY');
$config['username_domain'] = getenv('ROUNDCUBE_USERNAME_DOMAIN');
$config['htmleditor'] = intval(getenv('ROUNDCUBE_HTMLEDITOR') ?: 4);
$config['product_name'] = getenv('ROUNDCUBE_PRODUCT_NAME');
$config['draft_autosave'] = intval(getenv('ROUNDCUBE_DRAFT_AUTOSAVE') ?: 180);
$config['preview_pane'] = json_decode(getenv('ROUNDCUBE_PREVIEW_PANE') ?: 'true');

// Type of IMAP indexes cache. Supported values: 'db', 'apc' and 'memcache'.
$config['imap_cache'] = getenv('ROUNDCUBE_IMAP_CACHE');

// Enables messages cache. Only 'db' cache is supported.
$config['messages_cache'] = getenv('ROUNDCUBE_MESSAGES_CACHE') ?: false;

$config['imap_cache_ttl'] = getenv('ROUNDCUBE_IMAP_CACHE_TTL') ?: '10d';
$config['messages_cache_ttl'] = getenv('ROUNDCUBE_MESSAGES_CACHE_TTL') ?: '10d';
$config['messages_cache_threshold'] = intval(getenv('ROUNDCUBE_MESSAGES_CACHE_THRESHOLD') ?: 50);

// Backend to use for session storage. Can either be 'db' (default), 'redis', 'memcache', or 'php'
$config['session_storage'] = getenv('ROUNDCUBE_SESSION_STORAGE') ?: 'db';

// e.g. array( 'localhost:11211', '192.168.1.12:11211', 'unix:///var/tmp/memcached.sock' );
$config['memcache_hosts'] = json_decode(getenv('ROUNDCUBE_MEMCACHE_HOSTS') ?: '[]');
$config['sendmail_delay'] = intval(getenv('ROUNDCUBE_SENDMAIL_DELAY') ?: 5);
$config['max_recipients'] = intval(getenv('ROUNDCUBE_MAX_RECIPIENTS') ?: 100);
$config['email_dns_check'] = json_decode(getenv('ROUNDCUBE_EMAIL_DNS_CHECK') ?: 'false');

$config['plugins'] = json_decode(getenv('ROUNDCUBE_PLUGINS') ?: '[]');
if(getenv('ROUNDCUBE_USER_FILE')) $config['plugins'][] = 'password';
