#!/usr/bin/env bash

set -u

if [ -z "$RSFSX_INSTANCE" ]; then
    echo "RSFSX_INSTANCE environment variable is not set." >&2
    exit 1
fi

export RSFSX_CURRENT_PV_AREA_PREFIX=RSFSX_${RSFSX_INSTANCE}_PV_AREA_PREFIX
export RSFSX_CURRENT_PV_DEVICE_PREFIX=RSFSX_${RSFSX_INSTANCE}_PV_DEVICE_PREFIX
export RSFSX_CURRENT_DEVICE_IP=RSFSX_${RSFSX_INSTANCE}_DEVICE_IP
# Only works with bash
export EPICS_PV_AREA_PREFIX=${!RSFSX_CURRENT_PV_AREA_PREFIX}
export EPICS_PV_DEVICE_PREFIX=${!RSFSX_CURRENT_PV_DEVICE_PREFIX}
export EPICS_DEVICE_IP=${!RSFSX_CURRENT_DEVICE_IP}

# Create volume for autosave and ignore errors
/usr/bin/docker create \
    -v /opt/epics/startup/ioc/rsfsx-epics-ioc/iocBoot/iocrsfsx/autosave \
    --name rsfsx-epics-ioc-${RSFSX_INSTANCE}-volume \
    lnlsdig/rsfsx-epics-ioc:${IMAGE_VERSION} \
    2>/dev/null || true

# Remove a possible old and stopped container with
# the same name
/usr/bin/docker rm \
    rsfsx-epics-ioc-${RSFSX_INSTANCE} || true

/usr/bin/docker run \
    --net host \
    -t \
    --rm \
    --volumes-from rsfsx-epics-ioc-${RSFSX_INSTANCE}-volume \
    --name rsfsx-epics-ioc-${RSFSX_INSTANCE} \
    lnlsdig/rsfsx-epics-ioc:${IMAGE_VERSION} \
    -i "${EPICS_DEVICE_IP}" \
    -P "${EPICS_PV_AREA_PREFIX}" \
    -R "${EPICS_PV_DEVICE_PREFIX}" \
