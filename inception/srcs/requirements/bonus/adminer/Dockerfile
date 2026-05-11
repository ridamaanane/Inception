FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-cli \
    php-mysql \
    curl

RUN mkdir -p /var/www/html

RUN curl -L https://www.adminer.org/latest.php -o /var/www/html/index.php

# PHP server need this folder for index.php
WORKDIR /var/www/html 

CMD ["php", "-S", "0.0.0.0:8080"]