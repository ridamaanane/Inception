<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress_db' );

/** Database username */
define( 'DB_USER', 'wp_user' );

/** Database password */
define( 'DB_PASSWORD', 'wp_pass' );

/** Database hostname */
define( 'DB_HOST', 'mariadb:3306' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          '-3!)lkGw/Jd<hdrNu* Eu98uk:NC_xxv_jPe2qFou0mcG#1$t8~Lof&ughvBU?6t' );
define( 'SECURE_AUTH_KEY',   '(v-Xb4nDj7]dJ2_*|?4(fK*b!VL]0+*ka/`8qqVO>r>KL^ZXX?y;}kibeh[=FzDP' );
define( 'LOGGED_IN_KEY',     '632V:m0Cr_pbdZO_u=y}kNa8Y &cJa$oF;laUHUl[Tt EZUbu#[ymM$bbirGN)f6' );
define( 'NONCE_KEY',         'qxp%7!8k_y5:J:xL$MYq{;OGM?*zRil24uLWqMn)x66yH1)ugr^=ZTcsnlb:8=I4' );
define( 'AUTH_SALT',         ',]iy v0p8zXJ+3nj*}M5{p:*>rY]6AaBM}0WN!iSFj_eX=u&d`Oj-_ZJd[UhiS1T' );
define( 'SECURE_AUTH_SALT',  '/&oo*2/qK~l3Sjtc44(1eItZYwX>n!LA:5Zg:I;!Jw4e+xvX }z}om5Ip]8z3Yr ' );
define( 'LOGGED_IN_SALT',    'NGT.?RTL7k(]Xc,D0YkJ&D9)PC2$8qIo)~8Nxi>l-*y=h=}j5Gt4jdSrdbVgdXsH' );
define( 'NONCE_SALT',        'W(:S~eO}+iC*Fch5z Ya)GUI@g6q;HmBO9xtP%%rtfw4,8@f8i#yJUi)9_iX,FW|' );
define( 'WP_CACHE_KEY_SALT', 'z] +tcy`?m/0X(Or_MDwad:}eqsw.*<y`eR(|a acyBmO!ox~-HAfjV>92;i);`U' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
