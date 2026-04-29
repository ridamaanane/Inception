FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-client

COPY tools/script.sh .

RUN chmod +x script.sh

CMD [ "./script.sh" ]


