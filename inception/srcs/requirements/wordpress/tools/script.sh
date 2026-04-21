#!/bin/bash

mkdir -p /var/www/html
cd /var/www/html

# Wait for mariadb to be ready
until mysql -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT VERSION();" > /dev/null; do
    echo "Waiting for mariadb..."
    sleep 2
done

wp core download --allow-root

# creates file of wp-config.php
wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost=mariadb:3306 \
    --allow-root

# install wordpress
wp core install \
    --url="$DOMAIN_NAME" \
    --title="inception" \
    --admin_user="$WP_ADMIN" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --allow-root

mkdir -p /run/php

# install and activate Redis plugin
cd /var/www/html
wp plugin install redis-cache --activate --allow-root

#-q quite mode (without showing the output)
if ! grep -q "WP_REDIS_HOST" wp-config.php; then
    echo "define('WP_REDIS_HOST', 'redis');" >> wp-config.php
    echo "define('WP_REDIS_PORT', 6379);" >> wp-config.php
    echo "define('WP_CACHE', true);" >> wp-config.php
fi
wp redis enable --allow-root

exec php-fpm8.2 -F