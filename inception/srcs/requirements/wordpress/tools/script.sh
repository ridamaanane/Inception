#!/bin/bash

mkdir -p /var/www/html
cd /var/www/html

until mysql -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT VERSION();" > /dev/null; do
    echo "Waiting for mariadb..."
    sleep 2
done

#Downloads WordPress files only (wp-admin/ wp-content/ wp-includes/)
if [ ! -f wp-config.php ]; then
	wp core download --allow-root
fi

# creates file of wp-config.php
if [ ! -f wp-config.php ]; then
wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost=mariadb:3306 \
    --allow-root
fi

# install wordpress
if ! wp core is-installed --allow-root > /dev/null 2>&1; then
wp core install \
    --url="$DOMAIN_NAME" \
    --title="inception" \
    --admin_user="$WP_ADMIN" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --allow-root
fi

# create user wp
if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
    echo "Ceating second user..."

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
fi


# used by PHP-FPM for runtime files
mkdir -p /run/php 

# install Redis + activate plugin
wp plugin install redis-cache --activate --allow-root

#connect to the Redis container using Docker’s internal service name instead of localhost (we change wp-config.php)
wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT 6379 --allow-root

# remove old broken cache file BEFORE enabling (Use Redis instead of normal database queries for caching (without this rm we can't access to the website))
rm -f /var/www/html/wp-content/object-cache.php
    
wp redis enable --allow-root

exec php-fpm8.2 -F