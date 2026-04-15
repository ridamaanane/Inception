#!/bin/bash

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

until mysqladmin -S /var/run/mysqld/mysqld.sock ping --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

cd /var/www/html

wp core download --allow-root

echo "Creating WordPress config..."
#-dbhost=mariadb, means db mariadb that we set inside docker-compose
wp config create \
--dbname=$MYSQL_DATABASE \
--dbuser=$MYSQL_USER \
--dbpass=$MYSQL_PASSWORD \
--dbhost=localhost \
--dbsocket=/var/run/mysqld/mysqld.sock \
--allow-root
if [ $? -ne 0 ]; then
    echo "ERROR: wp config create failed!"
    # exit 1
fi

echo "Installing WordPress..."
# WE allow root because wp can't run as root for safety reason, (docker by default run commands as root)
wp core install \
    --url=https://rmaanane.42.fr \
    --title=inception \
    --admin_user=rmaanane \
    --admin_password=CanyouBruteForceMePass123! \
    --admin_email=rmaanane@student.1337.ma \
    --allow-root
if [ $? -ne 0 ]; then
    echo "ERROR: wp core install failed!"
    # exit 1
fi

echo "WordPress installed successfully!"
# php-fpm7.4 -F #This is the main process that keeps the container alive, -F = foreground mode
sleep infinity