FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    default-mysql-client \
    curl

RUN sed -i 's|listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf

# download wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

COPY tools/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 9000

CMD ["/script.sh"]