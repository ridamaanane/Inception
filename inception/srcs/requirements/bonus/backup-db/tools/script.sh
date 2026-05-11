#!/bin/bash

mkdir backup-db
cd backup-db


while true;
do
    mysqldump -u "$MYSQL_USER" -p"wp_pass" -h mariadb --all-databases > alldb.sql
    sleep 10
done

sleep infinity
