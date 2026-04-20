FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

# COPY my.cnf /etc/mysql/my.cnf / i removed my.cnf (useless)

RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld

COPY tools/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 3306

CMD ["/script.sh"]