#!/bin/bash
# check if the volume exists, otherwise refuse to build. It doesn't
# matter really, but nice to ensure that the volume is built, to prevent
# later errors.

CHECKVOL=$(docker volume inspect ${VOL} -f '{{.Name}}')
if [ "$CHECKVOL" != "$VOL" ]
then
   echo "Docker volume $VOL needs to be created."
   echo "Please run ./build_volume first."
   exit
fi

DOCKER_BUILDKIT=1 docker build -t $IMAGENAME \
                               -f Dockerfile-$DEBIANVER .