FROM alpine:3.14

RUN apk update
RUN apk add --no-cache openssh bash tar curl sshpass runuser net-tools busybox-extras iperf3
RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community


RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . .

RUN bash setup.sh

WORKDIR /usr/src/app

EXPOSE 30001 30002 30003 30004 30005 30006 30022

CMD bash start.sh

