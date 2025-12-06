#!/bin/bash

OUTDIR="$1"
INSTDIR="${OUTDIR}/install"
rm -rf "${INSTDIR}"
mkdir -p "${INSTDIR}"

docker build -t pacwebadmin-build .
docker create --name pacwebadmin-ubuntu pacwebadmin-build

docker cp pacwebadmin-ubuntu:/app/dist "${INSTDIR}/dist"
docker cp pacwebadmin-ubuntu:/app/pacwebadmin "${INSTDIR}/"

cp ./install/ubuntu/scripts/* "${INSTDIR}/"

rm -f "${OUTDIR}/install.tar.gz"

tar -cvzf "${OUTDIR}/install.tar.gz" -C "${OUTDIR}" install/
