FROM nginx:alpine

RUN apk add perl perl-dev libxml2-utils make
RUN cpan install -T Parse::RecDescent

WORKDIR /var/www
COPY . /var/www
RUN printf "#!/bin/sh\nmake -C /var/www\necho 'NOTICE: nginx.org development site is running at http://localhost:8001/'\nexec nginx -g 'daemon off;'" > /docker-entrypoint.sh
EXPOSE 8080
