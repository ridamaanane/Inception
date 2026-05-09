#!/bin/bash

mysqld --user=mysql --bind-address=0.0.0.0 &


sleep 5


if ! mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "USE ${MYSQL_DATABASE};" 2>/dev/null; then
    echo "Initializing database..."

    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" 
    
    #Create database
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE ${MYSQL_DATABASE};"

    #Create user, '%' = allow connection from anywhere
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    #allow user to fully control the DB
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
fi


#stop temporary DB, (we need to restart it)
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

exec mysqld --user=mysql --bind-address=0.0.0.0
