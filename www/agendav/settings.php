<?php

// Site title
$app['site.title'] = getenv('AGENDAV_TITLE');

// Site logo (should be placed in public/img). Optional
$app['site.logo'] = 'agendav_100transp.png';

// Site footer. Optional
$app['site.footer'] = getenv('AGENDAV_FOOTER');

// Trusted proxy ips
$app['proxies'] = [];

// Database settings
$app['db.options'] = [
        'dbname' => getenv('AGENDAV_DB_NAME'),
        'user' => getenv('AGENDAV_DB_USER'),
        'password' => getenv('AGENDAV_DB_PASSWORD'),
        'host' => 'postgres',
        'driver' => 'pdo_pgsql'
];

// Encryption key
$app['encryption.key'] = getenv('AGENDAV_ENC_KEY');

// Log path
$app['log.path'] = '/tmp/';

// Base URL
$app['caldav.baseurl'] = getenv('AGENDAV_CALDAV_BASEURL');

// Authentication method required by CalDAV server (basic or digest)
$app['caldav.authmethod'] = 'basic';

// Whether to show public CalDAV urls
$app['caldav.publicurls'] = true;

// Whether to show public CalDAV urls
$app['caldav.baseurl.public'] = getenv('AGENDAV_CALDAV_BASEURL_PUBLIC');

// Default timezone
$app['defaults.timezone'] = getenv('AGENDAV_TIMEZONE');

// Default languajge
$app['defaults.language'] = getenv('AGENDAV_LANG');

// Default time format. Options: '12' / '24'
$app['defaults.time.format'] = '24';

/*
 * Default date format. Options:
 *
 * - ymd: YYYY-mm-dd
 * - dmy: dd-mm-YYYY
 * - mdy: mm-dd-YYYY
 */
$app['defaults.date.format'] = 'ymd';

// Default first day of week. Options: 0 (Sunday), 1 (Monday)
$app['defaults.weekstart'] = 0;

// Logout redirection. Optional
$app['logout.redirection'] = '';

// Calendar sharing
$app['calendar.sharing'] = true;
