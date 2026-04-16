#!/bin/bash

set -e

start_mysqld() {
  mysqld --user=mysql --bind-address=0.0.0.0 &
  MYSQLD_PID=$!

  for i in {1..30}; do
    if mysqladmin ping --silent; then
      return 0
    fi
    echo "Waiting for mariadb startup... ($i)"
    sleep 1
done

  return 1
}

run_root_sql() {
  if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; then
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$@"
  else
    mysql -u root "$@"
  fi
}

if [ ! -d /var/lib/mysql/mysql ]; then
  mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi

start_mysqld

if ! mysqladmin ping --silent; then
  echo "MariaDB did not start in time"
  exit 1
fi

# Ensure root password is set when needed
if [ -n "$MYSQL_ROOT_PASSWORD" ] && ! mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; then
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"
fi

# Create the database if missing
if ! run_root_sql -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" | grep -q "$MYSQL_DATABASE"; then
  run_root_sql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
fi

# Create the WordPress user if missing
if ! run_root_sql -e "SELECT User, Host FROM mysql.user WHERE User='$MYSQL_USER' AND Host='%';" | grep -q "$MYSQL_USER"; then
  run_root_sql -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
  run_root_sql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
  run_root_sql -e "FLUSH PRIVILEGES;"
fi

mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown
wait $MYSQLD_PID

exec mysqld --user=mysql --bind-address=0.0.0.0