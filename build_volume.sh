#!/bin/sh
SRC="files"
DEST="/script"

echo "Removing null image"
docker rmi null
echo "Creating ${VOL} afresh"
docker volume create --name ${VOL}

echo "Making a new null image"
docker build -t null -f Dockerfile-volume .
docker container create --name empty -v ${VOL}:${DEST} null

echo "Copying from ${SRC} to ${DEST}"
for s in ${SRC}/*
do
   echo "$s -> ${DEST}"
   docker cp $s empty:${DEST}
done

echo "Done. Cleaning up containers"
docker rm empty
