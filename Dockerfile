FROM nginx:alpine AS build

RUN apk add netpbm perl perl-parse-recdescent libxslt libxml2-utils patch make rsync

COPY . /var/www
WORKDIR /var/www

COPY *.patch .
RUN touch null.patch && cat *.patch | patch -p1
RUN make images all gzip

FROM nginx:alpine
COPY --from=build /var/www /var/www 
COPY docker-nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
