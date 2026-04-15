FROM debian:bullseye

RUN apt update && apt upgrade -y && \
    apt install -y mariadb-server

COPY init.sh /init.sh

RUN chmod +x init.sh

ENTRYPOINT ["/init.sh"]

EXPOSE 3306