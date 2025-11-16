<?php

// production | staging | development
define('WP_ENV', 'development');

define('ENVIRONMENTS', serialize([
	// 'production'  => 'https://example.com',
	// 'staging'     => 'https://staging.example.com',
	'development' => 'http://wordpress.test',
]));

define('DB_NAME',     'wordpress_6.8');
define('DB_USER',     'dev');
define('DB_PASSWORD', 'dev');
define('DB_HOST',     'localhost');

$table_prefix = 'gl_';

// https://api.wordpress.org/secret-key/1.1/salt/
// You can change these at any point in time to invalidate all existing cookies.
define('AUTH_KEY',         'F$G77*<-F2EYo&V%#ElAPZ`a/#tDHF&%{G$K6rhdTmxzCs[ND+)q v{|!S)#nm=h');
define('SECURE_AUTH_KEY',  'wXf:e%+f+xZj1`0G!,1ZNOXLRhXo~MQrxJbK4 GOtB8C9ZMDD:`h9e?,8;1J<Tn.');
define('LOGGED_IN_KEY',    'P}%T@P_/XA$;PVWU0/F+6+Z:FvBP%jxBAgVjp|u,|_,Kr9qr;2kVw=e@#bKi^Y`#');
define('NONCE_KEY',        'CYpU?3odt`5ihluSRJV>cPfU%&Xf<a<Fe<<s034;Ed<Tjb89J2~2++}|+-X|`y20');
define('AUTH_SALT',        'G)t3dMru]|Z8~yx~S/;#nc[+9<7^7h&Pokco@9R(n`AIFaf05Ji!NItc=5+`3A[-');
define('SECURE_AUTH_SALT', 'X{:+q8aDt2[5X=-9P+w;yeD*`jo-xkgGV4T A+G,D-%|z/2!bO`$,9g*qxEkR)v.');
define('LOGGED_IN_SALT',   'U@JW<Danr1qY@^!XfsR^D4IJ>;~Uzwm:N*n2lamA.hYY-x1@F|SDY-]-taJ!H9#,');
define('NONCE_SALT',       'ZeX-<E<eyxZN+oG{%p#s^Z%pY+DIazS2unHmF7&r%8.N$1~/)GQGGsvHuZ$Vp*}K');

define('DISALLOW_FILE_EDIT', false);
define('SAVEQUERIES', true);
define('SCRIPT_DEBUG', true);
define('WP_DEBUG', true);
// define('MAILTRAP_USERNAME', 'c4c8a865fd8857');
// define('MAILTRAP_PASSWORD', 'a1796be3fb3546');
