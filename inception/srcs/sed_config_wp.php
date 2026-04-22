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
define( 'AUTH_KEY',          'k!kKDS@.xN#_$/Cd.e0,@8Y>k(1 w2qmRv!WSMEBSp{HgpOc9]lAB~e^6 N$0Y<!' );
define( 'SECURE_AUTH_KEY',   '))XB?,)M9s^UYM>78pVAKC`_5_T}b;PUmoa5G )eq%@J8b5juWQ7 #Ewq0)[[Ne|' );
define( 'LOGGED_IN_KEY',     'P$t)D[mO/j Ds_):(~K]kN!K#=Pok.KY%YUC1~5I~vXx2<e8S1cqR:?[h%u]djg+' );
define( 'NONCE_KEY',         's{}IO_2eB@)G~r=!!^*yhSf;r]~c(0=XtD~VwJDRu)q:<vYG0JAg),C5PpwWYqm:' );
define( 'AUTH_SALT',         '1}y)J,Q$nX?Z2)(QOY|M]3uT~}llMLNDRdao-k!Ce4 xS6rHP0#>{!EEssrv;[- ' );
define( 'SECURE_AUTH_SALT',  'L:m nbS-KGyp=a,Y0!T.l<2pnVs&zj/.C1T gSSob(:Z~@CSlKP-~ecw>.lZ7%.g' );
define( 'LOGGED_IN_SALT',    ';_>?R=<W5%o=847#,85mY>vL6<D|M1V #[{}!|H@5}BgtnEb;l}o}QSDJ:XKrc|m' );
define( 'NONCE_SALT',        ')a@AD35|+_`3qZ|iEEmi1x0?y*C@^y5qj.r5`&L6=C!7NtF5,i=q>U)5KCajwWNY' );
define( 'WP_CACHE_KEY_SALT', '*G3xCs05sxz5aiS6hyLvCL&-*ORN=Z,}L$W})ZvU9Z,|,P%O(nO/CzM|(?:BjlrF' );


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
define('WP_REDIS_HOST', 'redis');    define('WP_REDIS_PORT', 6379);    define('WP_CACHE', true);
require_once ABSPATH . 'wp-settings.php';
