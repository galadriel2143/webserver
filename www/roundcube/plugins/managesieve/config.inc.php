<?php

// managesieve server port. When empty the port will be determined automatically
// using getservbyname() function, with 4190 as a fallback.
$config['managesieve_port'] = getenv('MANAGESIEVE_PORT') ?: 4190;

// managesieve server address, default is localhost.
// Replacement variables supported in host name:
// %h - user's IMAP hostname
// %n - http hostname ($_SERVER['SERVER_NAME'])
// %d - domain (http hostname without the first part)
// For example %n = mail.domain.tld, %d = domain.tld
$config['managesieve_host'] = getenv('MANAGESIEVE_HOST') ?: 'localhost';

// authentication method. Can be CRAM-MD5, DIGEST-MD5, PLAIN, LOGIN, EXTERNAL
// or none. Optional, defaults to best method supported by server.
$config['managesieve_auth_type'] = getenv('MANAGESIEVE_AUTH_TYPE') ?: null;

// Optional managesieve authentication identifier to be used as authorization proxy.
// Authenticate as a different user but act on behalf of the logged in user.
// Works with PLAIN and DIGEST-MD5 auth.
$config['managesieve_auth_cid'] = getenv('MANAGESIEVE_AUTH_CID') ?: null;

// Optional managesieve authentication password to be used for imap_auth_cid
$config['managesieve_auth_pw'] = getenv('MANAGESIEVE_AUTH_PM') ?: null;

// use or not TLS for managesieve server connection
// Note: tls:// prefix in managesieve_host is also supported
$config['managesieve_usetls'] = json_decode(getenv('MANAGESIEVE_USETLS') ?: 'false');

// Connection scket context options
// See http://php.net/manual/en/context.ssl.php
// The example below enables server certificate validation
//$config['managesieve_conn_options'] = array(
//  'ssl'         => array(
//     'verify_peer'  => true,
//     'verify_depth' => 3,
//     'cafile'       => '/etc/openssl/certs/ca.crt',
//   ),
// );
// Note: These can be also specified as an array of options indexed by hostname
$config['managesieve_conn_options'] = json_decode(getenv('MANAGESIEVE_CONN_OPTIONS') ?: 'null');

// default contents of filters script (eg. default spam filter)
$config['managesieve_default'] = getenv('MANAGESIEVE_DEFAULT') ?: '/etc/dovecot/sieve/global';

// The name of the script which will be used when there's no user script
$config['managesieve_script_name'] = getenv('MANAGESIEVE_SCRIPT_NAME') ?: 'managesieve';

// Sieve RFC says that we should use UTF-8 endcoding for mailbox names,
// but some implementations does not covert UTF-8 to modified UTF-7.
// Defaults to UTF7-IMAP
$config['managesieve_mbox_encoding'] = getenv('MANAGESIEVE_MBOX_ENCODING') ?: 'UTF-8';

// I need this because my dovecot (with listescape plugin) uses
// ':' delimiter, but creates folders with dot delimiter
$config['managesieve_replace_delimiter'] = getenv('MANAGESIEVE_REPLACE_DELIMITER') ?: '';

// disabled sieve extensions (body, copy, date, editheader, encoded-character,
// envelope, environment, ereject, fileinto, ihave, imap4flags, index,
// mailbox, mboxmetadata, regex, reject, relational, servermetadata,
// spamtest, spamtestplus, subaddress, vacation, variables, virustest, etc.
// Note: not all extensions are implemented
$config['managesieve_disabled_extensions'] = json_decode(getenv('MANAGESIEVE_DISABLED_EXTENSIONS') ?: '[]');

// Enables debugging of conversation with sieve server. Logs it into <log_dir>/sieve
$config['managesieve_debug'] = json_decode(getenv('MANAGESIEVE_DEBUG') ?: 'false');

// Enables features described in http://wiki.kolab.org/KEP:14
$config['managesieve_kolab_master'] = json_decode(getenv('MANAGESIEVE_KOLAB_MASTER') ?: 'false') ;

// Script name extension used for scripts including. Dovecot uses '.sieve',
// Cyrus uses '.siv'. Doesn't matter if you have managesieve_kolab_master disabled.
$config['managesieve_filename_extension'] = getenv('MANAGESIEVE_FILENAME_EXTENSION') ?: '.sieve';

// List of reserved script names (without extension).
// Scripts listed here will be not presented to the user.
$config['managesieve_filename_exceptions'] = json_decode(getenv('MANAGESIEVE_FILENAME_EXCEPTIONS') ?: '[]');

// List of domains limiting destination emails in redirect action
// If not empty, user will need to select domain from a list
$config['managesieve_domains'] = json_decode(getenv('MANAGESIEVE_DOMAINS') ?: '[]');

// Enables separate management interface for vacation responses (out-of-office)
// 0 - no separate section (default),
// 1 - add Vacation section,
// 2 - add Vacation section, but hide Filters section
$config['managesieve_vacation'] = intval(getenv('MANAGESIEVE_VACATION') ?: 0);

// Default vacation interval (in days).
// Note: If server supports vacation-seconds extension it is possible
// to define interval in seconds here (as a string), e.g. "3600s".
$config['managesieve_vacation_interval'] = intval(getenv('MANAGESIEVE_VACATION_INTERVAL') ?: 0);

// Some servers require vacation :addresses to be filled with all
// user addresses (aliases). This option enables automatic filling
// of these on initial vacation form creation.
$config['managesieve_vacation_addresses_init'] = json_decode(getenv('MANAGESIEVE_VACATION_ADDRESSES_INIT') ?: 'false');

// Sometimes you want to always reply with mail email address
// This option enables automatic filling of :from field on initial vacation form creation.
$config['managesieve_vacation_from_init'] = json_decode(getenv('MANAGESIEVE_VACATION_FROM_INIT') ?: 'false');

// Supported methods of notify extension. Default: 'mailto'
$config['managesieve_notify_methods'] = json_decode(getenv('MANAGESIEVE_NOTIFY_METHODS') ?: '["mailto"]');

// Enables scripts RAW editor feature
$config['managesieve_raw_editor'] = json_decode(getenv('MANAGESIEVE_RAW_EDITOR') ?: 'true');
