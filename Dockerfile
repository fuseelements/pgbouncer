FROM alpine:latest AS build_stage

WORKDIR /tmp

RUN apk --update --no-cache add \
        autoconf \
        autoconf-doc \
        automake \
        c-ares \
        c-ares-dev \
        curl \
        gcc \
        libc-dev \
        libevent \
        libevent-dev \
        libtool \
        make \
        libressl-dev \
        file \
        pkgconf

ARG PGBOUNCER_VERSION=1.12.0

RUN curl -Lso "/tmp/pgbouncer.tar.gz" \
        "https://pgbouncer.github.io/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz"

RUN mkdir /tmp/pgbouncer && \
        tar -zxvf pgbouncer.tar.gz -C /tmp/pgbouncer --strip-components 1

WORKDIR /tmp/pgbouncer

RUN ./configure --prefix=/pgbouncer && \
        make && \
        make install


FROM alpine:latest

RUN apk --update --no-cache add \
        libevent \
        libressl \
        ca-certificates \
        c-ares \
        openssl \
        postgresql-client

WORKDIR /

COPY --from=build_stage /pgbouncer /pgbouncer

ADD entrypoint.sh ./

ENTRYPOINT ["./entrypoint.sh"]
