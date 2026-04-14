FROM debian:bullseye

RUN apt install -y \
php \
php-fpm \
php-mysql \
wget \
curl \
tar

RUN mkdir -p /var/www/html

#after this line Every next command acts as if you are inside this path
WORKDIR /var/www/html

EXPOSE 9000