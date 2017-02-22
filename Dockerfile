FROM alpine
MAINTAINER Christoph Wiechert <wio@psitrax.de>

ENV REFRESHED_AT="2017-01-17" \
    POWERDNS_VERSION=4.0.2

RUN apk --update add mysql-client mariadb-client-libs libpq sqlite-libs libstdc++ libgcc && \
    apk add --virtual build-deps \
      g++ make mariadb-dev postgresql-dev sqlite-dev curl boost-dev && \
    curl -sSL https://downloads.powerdns.com/releases/pdns-$POWERDNS_VERSION.tar.bz2 | tar xj -C /tmp && \
    cd /tmp/pdns-$POWERDNS_VERSION && \
    ./configure --prefix="" --exec-prefix=/usr --sysconfdir=/etc/pdns \
      --with-modules="bind gmysql gpgsql gsqlite3" --without-lua && \
    make && make install-strip && cd / && \
    mkdir -p /etc/pdns/conf.d && \
    addgroup -S pdns 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns 2>/dev/null && \
    apk del --purge build-deps && \
    rm -rf /tmp/pdns-$POWERDNS_VERSION /var/cache/apk/*


EXPOSE 53/tcp 53/udp

ADD mysql.schema.sql pgsql.schema.sql sqlite3.schema.sql pdns.conf /etc/pdns/

ADD tini /bin/tini
ENTRYPOINT ["tini","powerdns"]
ADD entrypoint.sh /bin/powerdns

EXPOSE 53/tcp 53/udp

ENV AUTOCONF=mysql \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306" \
    MYSQL_USER="root" \
    MYSQL_PASS="root" \
    MYSQL_DB="pdns" \
    PGSQL_HOST="postgres" \
    PGSQL_PORT="5432" \
    PGSQL_USER="postgres" \
    PGSQL_PASS="postgres" \
    PGSQL_DB="pdns" \
    SQLITE_DB="pdns.sqlite3"
