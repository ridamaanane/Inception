FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-client \
    cron

RUN mkdir backup-db

WORKDIR  backup-db

COPY tools/backup.sh .

RUN chmod +x backup.sh && \
    touch backup-cron

# backup every 5 minutes
RUN echo "*/5 * * * * /backup-db/backup.sh" > backup-cron && \
    mv backup-cron /etc/cron.d && \
    crontab /etc/cron.d/backup-cron

CMD [ "cron" , "-f" ]


