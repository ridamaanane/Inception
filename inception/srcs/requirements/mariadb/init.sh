#!/bin/bash

echo "Starting MariaDB initialization..."

# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql || echo "mysql_install_db failed"
fi

# Ensure correct permissions
echo "Setting permissions..."
chown -R mysql:mysql /var/lib/mysql || echo "chown failed"

echo "Starting mysqld_safe..."
mysqld_safe --user=mysql & # run as mysql user
sleep 10 #waits until DB is ready , we set 10 bcs it's safe delay

echo "Creating database and user..."
# -e means execute command
# we write IF NOT EXISTS For safety Second run to avoid recreate database
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" || echo "Failed to create database"
mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" || echo "Failed to create user"
mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';" || echo "Failed to grant privileges"
mysql -u root -e "FLUSH PRIVILEGES;" || echo "Failed to flush privileges"
# FLUSH pr.. means reload user permissions immediately

echo "MariaDB initialization complete."

# Keep the container running by waiting for the background mysqld_safe
wait