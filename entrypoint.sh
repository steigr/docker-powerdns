#!/bin/sh
set -e

# Wrap inside tini if it is not already running.
pidof tini >/dev/null 2>/dev/null </dev/null || exec tini -- "$0" "${@}"

# show traces
[ -z "$TRACE" ] || set -x

# --help, --version
[ "$1" = "--help" ] || [ "$1" = "--version" ] && exec pdns_server $1

# treat everything except -- as exec cmd
[ "${1:0:2}" != "--" ] && exec "$@"

if $MYSQL_AUTOCONF ; then
  . /etc/pdns/backend/mysql-backend.sh
fi

# Run pdns server
trap "pdns_control quit" SIGHUP SIGINT SIGTERM

pdns_server "$@" &

wait
