FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    mariadb-client \
    curl
#     redis-tools
# #redis-tools (cli)

RUN sed -i 's|listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

# download wp-cli (gets the file)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
# /usr/local/bin/wp directory in system PATH, (we move the file and we rename it to wp, (mv well do two things))
RUN mv wp-cli.phar /usr/local/bin/wp  

COPY tools/script.sh /script.sh
RUN chmod +x /script.sh

EXPOSE 9000

CMD ["/script.sh"]