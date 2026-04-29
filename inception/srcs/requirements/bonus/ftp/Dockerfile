FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    curl

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/script.sh /script.sh
RUN chmod +x /script.sh

CMD ["/script.sh"]