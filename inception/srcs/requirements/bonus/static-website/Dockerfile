FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx

COPY tools/index.html /var/www/html/
COPY tools/style.css /var/www/html/
COPY tools/rmaanane.jpg /var/www/html/

CMD ["nginx", "-g", "daemon off;"]