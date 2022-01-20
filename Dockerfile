FROM alpine:3.15.0

ENV LANG=C.UTF-8 TZ=Asia/Shanghai PUBLISH_DIR=/publish

RUN mkdir -p $PUBLISH_DIR

RUN apk add --update --no-cache curl gnupg gzip

RUN gpg --receive-keys ED97E90E62AA7E34

COPY download-iana-tzdata.sh /etc/periodic/daily/download-iana-tzdata.sh

VOLUME /publish

CMD crond -f

