FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    curl

COPY conf/vsftpd.conf /etc/vsftpd.conf

RUN useradd -m -d /var/www/html -s /bin/bash rmaanane && \
    echo "rmaanane:password" | chpasswd

EXPOSE 21

CMD ["vsftpd", "/etc/vsftpd.conf"]