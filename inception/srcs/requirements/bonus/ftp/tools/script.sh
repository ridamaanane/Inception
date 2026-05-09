#!/bin/bash

useradd -m -d /var/www/html -s /bin/bash "${FTP_USER}"

echo "${FTP_USER}:${FTP_PASS}" | chpasswd

# crete empty file to fix the issue of 500 OOPS
mkdir -p /var/run/vsftpd/empty

vsftpd /etc/vsftpd.conf