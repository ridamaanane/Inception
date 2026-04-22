FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server

COPY /conf/redis.conf /etc/redis/

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]