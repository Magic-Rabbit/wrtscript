#!/bin/bash

TARGET=armvirt
ARCH=armvirt
SUBTARGET=-1
#PROFILE=-1
VERSION=-1
KERNEL_GIT=-1
KERNEL_GIT_REF=-1
KERNEL_TREE_URL=-1
LUCI="n"

JOBS=1
VOL="compile_volume-stretch"
DEBIANVER=stretch


while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--arch)
            ARCH="$2"
            shift
            shift
            ;;
        -k|--kernel-git)
            KERNEL_GIT="$2"
            shift
            shift
            ;;
        -u|--kernel-tree-url)
            KERNEL_TREE_URL="$2"
            shift
            shift
            ;;
        -r|--kernel-git-ref)
            KERNEL_GIT_REF="$2"
            shift
            shift
            ;;
        -v|--version)
            VERSION="$2"
            shift
            shift
            ;;
        -t|--target)
            TARGET="$2"
            shift
            shift
            ;;
        -s|--subtarget)
            SUBTARGET="$2"
            shift
            shift
            ;;
        -j|--jobs)
            JOBS="$2"
            shift
            shift
            ;;
        -l|--luci)
            LUCI="y"
            shift
            ;;
        -*|--*)
            echo "Error: unknown option $1"
            exit 1
            ;;
    esac
done

if [ $TARGET == -1 ] && [ $SUBTARGET != -1 ]; then
    echo "Error: using subtarget without specifying a target"
    exit 1
fi

if [ $VERSION == -1 ]; then
    echo "Error: please specify the version."
    exit 1
fi

if [ $VERSION \< "v17.01.4" ]; then
    DEBIANVER=wheezy
elif [ $VERSION \< "v20.07.0" ]; then
    DEBIANVER=jessie
else
    DEBIANVER=stretch
fi

docker rm docker_script-$DEBIANVER

VOL="compile_volume-$DEBIANVER"
IMAGENAME="compile_script-$DEBIANVER"

. ./build_volume.sh
. ./build_image.sh
. ./dockrun.sh

if [ $SUBTARGET == -1 ]; then
    docker cp docker_script-$DEBIANVER:/script/openwrt/subtarget.txt .
    SUBTARGET=`cat subtarget.txt`
fi

mkdir -p result/$ARCH

docker cp docker_script-$DEBIANVER:/script/openwrt/bin/targets/$ARCH ./result/$ARCH/$VERSION-$TARGET-$SUBTARGET/
docker rm docker_script-$DEBIANVER