<?php

// production | staging | development
define('WP_ENV', 'development');

define('ENVIRONMENTS', serialize([
	// 'production'  => 'http://geminilabs.io',
	// 'staging'     => 'http://wordpress.geminilabs.io',
	'development' => 'http://wordpress.dev',
]));

define('DB_NAME',     'wordpress_4.6');
define('DB_USER',     'dev');
define('DB_PASSWORD', 'dev');
define('DB_HOST',     'localhost');

$table_prefix = 'gl_';

// https://api.wordpress.org/secret-key/1.1/salt/
// You can change these at any point in time to invalidate all existing cookies.
define('AUTH_KEY',         'oC-R*)l}NC#?7 F7=(q&7SEP,1*{+ipPu`R%tG2e5cW-_n]:A.S+|9CL|(SgtUgz');
define('SECURE_AUTH_KEY',  '0`}H){0vE.p&MFF05Vaz;koLRnGcRF:,7(fM|NpB3[0iw+3Sz=j5!Ly&7 %OV|Wr');
define('LOGGED_IN_KEY',    'N:}8(pf4yS%k#17/l%&q9X;ti70?T,|P}BW3K&FDeGp.{ _V4=okb(Xrg-0,6)6]');
define('NONCE_KEY',        '9aL6z)TF4%-|p+-<Xn^lQ!B(|w9Bq]hQ:1Lt#(=hvQk`d:[-A*=Sq76mGX9i)bY3');
define('AUTH_SALT',        '?W,8t-)bP/oF$/wyhLd:gFR6~I:hA%!*tAQT}Ao},TCovm=]lCgti/A3^K?Pkfja');
define('SECURE_AUTH_SALT', '1pQTF !,dszQp`S}ai~n/BIGZ&~.rP`h<hFBe  |(h7d>3@gju:<RikPxw8Yxc&>');
define('LOGGED_IN_SALT',   '`YU5dm<:/QcNP74$Xrpp^Y%-szo2WMsiFWxZ[y;<D2Y.TdMQn/f/Y,2!aSr(HvX#');
define('NONCE_SALT',       '2Q^x7+Ph>7A^t1 G(=gG7yLni):TQJ7I0=]k=X+*RS|Dv=dh!zx]~]n:2{AF=tj(');

// define('AUTOMATIC_UPDATER_DISABLED', true);
// define('DISALLOW_FILE_EDIT', true);
define('SAVEQUERIES', true);
define('SCRIPT_DEBUG', true);
define('WP_DEBUG', true);
