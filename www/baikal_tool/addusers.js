'use strict';
var casper = require('casper').create();

var options = casper.cli.options;

var BAIKAL_ADMIN_PASSWORD = options['admin-password'];
var CONTAINER_DOMAIN_NAME = options['container-domain-name'];
var BAIKAL_ADMIN_USERNAME = options['admin-username'];
var user = casper.cli.args[0];
var spl = user.split(':');

var email = spl[0];
var password = spl[1];

if(!BAIKAL_ADMIN_PASSWORD
    || !BAIKAL_ADMIN_USERNAME
    || !CONTAINER_DOMAIN_NAME
    || !user
    || !email
    || !password
) {
    casper.start("https://google.com/");

    casper.then(function() {
        this.echo(JSON.stringify(options, null, 4));
        this.echo(" \n\
Syntax: \n\
    --admin-password=: Login password \n\
    --admin-username=: Login username \n\
    --container-domain-name=: Domain of Baikal server \n\
");
    });
}
else {
    casper.start('https://' + CONTAINER_DOMAIN_NAME + '/admin/');

    casper.then(function() {
        var blarg = this.evaluate(function() {
            return document.body.innerHTML;
        });

        this.echo('Logging in as admin...');
        this.fillSelectors('form', {
            'input[name="login"]': BAIKAL_ADMIN_USERNAME,
            'input[name="password"]': BAIKAL_ADMIN_PASSWORD,
        });
    });

    casper.then(function() {
        this.echo('Clicking submit...');
        this.click('form button[type="submit"]');
    });

    casper.waitForSelector("ul.nav");

    casper.thenOpen('https://' + CONTAINER_DOMAIN_NAME + '/admin/?/users/new/1/');

    casper.waitForSelector("header a");

    casper.then(function() {
        this.echo('Clicking new user button...');
        this.click('header a');
    });

    casper.waitForSelector("#username");

    casper.then(function() {
        this.echo('Filling out new user form...');

        this.fillSelectors('form', {
            '#username': email,
            '#password': password,
            '#displayname': email,
            '#email': email,
            '#passwordconfirm': password,
        });
    });

    casper.then(function() {
        this.echo('Submitting...');
        this.click('form button[type="submit"]');
    });

    casper.wait(2000);
}

casper.run();
