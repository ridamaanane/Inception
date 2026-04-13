# bullseye is a tag nam of version 11 
FROM debian:bullseye   

RUN apt update && apt upgrade -y && apt install -y nginx openssl

RUN mkdir /etc/nginx/ssl

#we put destination same as source to avoid problems
COPY nginx.conf /etc/nginx/nginx.conf 

#generate SSL
RUN openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/nginx/ssl/nginx.key \
-out /etc/nginx/ssl/nginx.crt \
-subj "/C=MA/ST=Marrakech-Safi/L=Benguerir/O=1337/OU=student/CN=localhost"


EXPOSE 443

#runtime [means , When the container starts, run this command] , Because Docker needs a to be main process to keep alive.
CMD ["nginx", "-g", "daemon off;"]