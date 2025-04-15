#!/bin/sh

set -e

if [ -z $1 ]; then
    bin/console theme:compile || true
    /usr/bin/supervisord
else
    exec "$@"
fi
