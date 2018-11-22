#!/usr/bin/env bash

set -u

if [ -z "$RSFSX_INSTANCE" ]; then
    echo "RSFSX_INSTANCE environment variable is not set." >&2
    exit 1
fi

/usr/bin/docker stop \
    rsfsx-epics-ioc-${RSFSX_INSTANCE}
