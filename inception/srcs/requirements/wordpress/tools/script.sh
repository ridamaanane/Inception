#!/bin/bash

mkdir -p /var/www/html
cd /var/www/html

until mysql -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT VERSION();" > /dev/null; do
    echo "Waiting for mariadb..."
    sleep 2
done

#Downloads WordPress files only (wp-admin/ wp-content/ wp-includes/)
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

# used by PHP-FPM for runtime files
mkdir -p /run/php 

cd /var/www/html
#configure wp-config
cp /wp-config.php .

# install Redis + activate plugin
wp plugin install redis-cache --activate --allow-root

# remove old broken cache file BEFORE enabling (Use Redis instead of normal database queries for caching (without this rm we can't access to the website))

rm -f /var/www/html/wp-content/object-cache.php
    
wp redis enable --allow-root

exec php-fpm8.2 -F