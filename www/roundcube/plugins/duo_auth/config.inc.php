<?php
//	Duo Integration Key. 
$rcmail_config['IKEY'] = getenv('DUO_AUTH_IKEY');
//	Duo Secret Key
$rcmail_config['SKEY'] = getenv('DUO_AUTH_SKEY');
//	Duo API Host
$rcmail_config['HOST'] = getenv('DUO_AUTH_HOST');
//	Duo Application Key. Generate yourself (at least 40 characters long) and keep it secret from Duo.
//	You can generate a random string in Python with
//	import os, hashlib
//	print hashlib.sha1(os.urandom(32)).hexdigest()
$rcmail_config['AKEY'] = getenv('DUO_AUTH_AKEY');
?>
