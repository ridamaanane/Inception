#!/bin/bash

mysqldump -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -h mariadb --all-databases > /backup-db/alldb.sql


