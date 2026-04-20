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

exec php-fpm7.4 -F