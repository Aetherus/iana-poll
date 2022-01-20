FROM alpine:3.15.0

ENV LANG=C.UTF-8 TZ=Asia/Shanghai PUBLISH_DIR=/publish

RUN mkdir -p $PUBLISH_DIR

RUN apk add --update --no-cache curl gnupg gzip

COPY download-iana-tzdata.sh /etc/periodic/daily/download-iana-tzdata.sh

VOLUME /publish

CMD crond -f

