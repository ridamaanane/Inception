#!/bin/bash

mkdir backup-db
cd backup-db


while true;
do
    mysqldump -u wp_user -pwp_pass -h mariadb --all-databases > alldb.sql
    sleep 10
done

sleep infinity
