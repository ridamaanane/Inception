FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

RUN mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

COPY my.cnf /etc/mysql/my.cnf

RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld

COPY tools/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 3306

CMD ["/script.sh"]