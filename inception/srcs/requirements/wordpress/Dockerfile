FROM debian:bullseye

RUN apt update && apt upgrade -y

#We group this packages for faster and fewer layers in Docker and cleaner build
RUN apt install -y php php-fpm php-mysql curl mariadb-client

RUN mkdir -p /var/www/html

#after this line Every next command acts as if you are inside this path
WORKDIR /var/www/html

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT  ["/entrypoint.sh"]
#WHY ENTRYPOINT IS REQUIRED Because only at runtime: MariaDB exists, network exists, services can communicate

EXPOSE 9000