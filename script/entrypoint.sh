#!/bin/sh

set -e

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
NORMAL=$(tput sgr0)

echo "$CYAN START OPEN-SDK-ESP FOR ESP8266 $NORMAL"

if [ "$1" = 'build' ]; then
    /usr/local/bin/build.sh
else
    if [ "$1" = 'bash' ]; then
        /bin/bash
    elif [ -z "$1" ]; then
        /bin/bash
    else
        exec "$@"
    fi
fi