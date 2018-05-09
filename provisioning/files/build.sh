#!/usr/bin/env bash

BUILD="${1}"
BUILDDATE=$(date +%Y%m%d)
BUILDROOT="/opt/buildroot/${BUILD}/${BUILDDATE}/"

ALLOWED="$(jq -r '.build_versions[]' /opt/build_versions.json |tr '\n' ' ')"

if [ "${#}" -ne 1 ]; then
    echo "USAGE: $(basename "${0}") container."
    exit 1
elif [[ "${ALLOWED}" =~ "${BUILD}" ]]; then
    if [ ! -d "${BUILDROOT}" ]; then
	mkdir -p ${BUILDROOT}
    else
	echo "${BUILDROOT} already exists. Overwriting."
    fi
else
    echo "${BUILD} is an unknown container build. Exiting."
    echo "Allowed: ${ALLOWED}"
    exit 1
fi

time livemedia-creator \
     --logfile=${BUILDROOT}/"${BUILD}".log \
     --no-virt \
     --make-tar \
     --ks /opt/"${BUILD}"-ks \
     --image-name="${BUILD}"-docker.tar.xz \
     --project="CentOS 7 Docker (MoJ)" \
     --releasever "7"

cp /var/tmp/"${BUILD}"-docker.tar.xz /var/www/html/

exit 0
