FROM nginx:alpine

RUN apk add perl perl-parse-recdescent libxml2-utils make inotify-tools

WORKDIR /var/www
COPY . /var/www
COPY tools/entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 8080
