FROM alpine:3.13

LABEL maintainer="i@yangliu.name"

ENV MODE="server"

# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache rsync openssh tzdata curl ca-certificates docker-cli && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /scripts

ADD entrypoint.sh /

VOLUME [ "/scripts" ]
WORKDIR /scripts


ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh"]