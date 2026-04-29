FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php

WORKDIR /var/www/html

COPY tools/index.html .
COPY tools/style.css .
COPY tools/rmaanane.jpg .


CMD ["php", "-S", "0.0.0.0:69"]