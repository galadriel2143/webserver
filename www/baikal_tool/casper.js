'use strict';
var casper = require('casper').create();

var options = casper.cli.options;

var BAIKAL_DAV_AUTH_TYPE = options['dav-auth-type'];
var CONTAINER_DOMAIN_NAME = options['container-domain-name'];
var BAIKAL_TIMEZONE = options['timezone'];
var BAIKAL_ADMIN_PASSWORD = options['admin-password'];
var BAIKAL_DB_HOST = options["db-host"];
var BAIKAL_DB_NAME = options["db-name"];
var BAIKAL_DB_USER = options["db-user"];
var BAIKAL_DB_PASSWORD = options["db-password"];

if(
    !BAIKAL_DAV_AUTH_TYPE
    || !CONTAINER_DOMAIN_NAME
    || !BAIKAL_TIMEZONE
    || !BAIKAL_ADMIN_PASSWORD
    || !BAIKAL_DB_HOST
    || !BAIKAL_DB_NAME
    || !BAIKAL_DB_USER
    || !BAIKAL_DB_PASSWORD
) {
    casper.start("https://google.com/");

    casper.then(function() {
        this.echo(JSON.stringify(options, null, 4));
        this.echo(" \n\
Syntax: \n\
    --timezone=: America/New_York \n\
    --dav-auth-type=: Digest or Basic \n\
    --admin-password=: Login password \n\
    --db-host=: DB Host \n\
    --db-name=: DB name \n\
    --db-user=: DB user \n\
    --db-password=: DB password \n\
    --container-domain-name=: Domain of Baikal server \n\
");
    });
}
else {
    casper.start('https://' + CONTAINER_DOMAIN_NAME + '/admin/install/');

    casper.then(function() {
        this.echo('Filling out admin info...');
        this.fillSelectors('form', {
            '#PROJECT_TIMEZONE': BAIKAL_TIMEZONE,
            '#BAIKAL_DAV_AUTH_TYPE': BAIKAL_DAV_AUTH_TYPE,
            '#BAIKAL_ADMIN_PASSWORDHASH': BAIKAL_ADMIN_PASSWORD,
            '#BAIKAL_ADMIN_PASSWORDHASH_CONFIRM': BAIKAL_ADMIN_PASSWORD,
        });
    })

    casper.then(function() {
        this.click('form button[type="submit"]');
    });

    casper.waitForSelector("#PROJECT_DB_MYSQL");

    casper.then(function() {
        this.click("#PROJECT_DB_MYSQL");
    });

    casper.waitForSelector("#PROJECT_DB_MYSQL_HOST");

    casper.then(function() {
        this.echo('Filling out DB info...');
        this.fillSelectors('form', {
            "#PROJECT_DB_MYSQL_HOST": BAIKAL_DB_HOST,
            "#PROJECT_DB_MYSQL_DBNAME": BAIKAL_DB_NAME,
            "#PROJECT_DB_MYSQL_USERNAME": BAIKAL_DB_USER,
            "#PROJECT_DB_MYSQL_PASSWORD": BAIKAL_DB_PASSWORD,
        });
    });

    casper.then(function() {
        this.click('form button[type="submit"]');
    });
}

casper.run();
