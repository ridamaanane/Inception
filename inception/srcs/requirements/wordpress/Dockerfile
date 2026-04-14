FROM debian:bullseye

#We group this packages for faster and fewer layers in Docker and cleaner build
RUN apt install -y php php-fpm php-mysql curl

RUN mkdir -p /var/www/html

#after this line Every next command acts as if you are inside this path
WORKDIR /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# WE allow root because wp can't run as root for safety reason, (docker by default run commands as root)
#We seaparate commands because before we do not have files , we can't run this with prev one
RUN wp core download --allow-root 

#-dbhost=mariadb, means db mariadb that we set inside docker-compose
RUN wp config create --dbname=YOUR_DB_NAME --dbuser=YOUR_DB_USER --dbpass=YOUR_DB_PASSWORD --dbhost=mariadb

RUN wp core install \
    --url=https://rmaanane.42.fr \
    --title=inception \
    --admin_user=rmaanane \
    --admin_password=CanyouBruteForceMePass123! \
    --admin_email=rmaanane@student.1337.ma \
    --allow-root

EXPOSE 9000