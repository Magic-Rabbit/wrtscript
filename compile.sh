#!/bin/bash

TARGET=armvirt
ARCH=armvirt
SUBTARGET=-1
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

rm -rf ./result/$ARCH/$VERSION-$TARGET-$SUBTARGET
docker cp docker_script-$DEBIANVER:/script/openwrt/bin/targets/$ARCH ./result/$ARCH/$VERSION-$TARGET-$SUBTARGET
docker rm docker_script-$DEBIANVER

# QEMU run script generation
cd ./result/$ARCH/$VERSION-$TARGET-$SUBTARGET
KERNEL_NAME=-1
if [ $ARCH == armvirt ]; then
    QEMU_ARCH=arm
    MACHINE=virt-2.7
    NOGRAPHIC=-nographic
    APPEND="root=/dev/vda"
    KERNEL_NAME=zImage
    HDA_NAME=ext4
elif [ $ARCH == x86 ]; then
    QEMU_ARCH=x86_64
    APPEND="root=/dev/sda"
    KERNEL_NAME=vmlinuz
    HDA_NAME=rootfs-ext4
else
    echo "Error: unknown target. QEMU run script won't be generated."
    exit 1
fi

KERNEL=$(find . -name *$KERNEL_NAME)
if [ KERNEL == "" ]; then
    echo "Error: can't find kernel file. Maybe compilation was unsuccessful."
    exit 1
fi

HDA=$(find . -name *$HDA_NAME*)
gunzip $HDA
HDA=$(find . -name *$HDA_NAME*)

if [ HDA == "" ]; then
    echo "Error: can't find filesystem file. Maybe compilation was unsuccessful."
    exit 1
fi

cat > run.sh << EOF
qemu-system-$QEMU_ARCH \
-M $MACHINE \
-m 256 \
-device virtio-net,netdev=net0 -netdev user,id=net0,net=192.168.1.0/24,hostfwd=tcp:127.0.0.1:11122-192.168.1.1:22,hostfwd=tcp:127.0.0.1:11180-192.168.1.1:80 \
-device virtio-net,netdev=net1 -netdev user,id=net1,net=192.0.2.0/24 \
-kernel $KERNEL \
-hda $HDA \
-append $APPEND $NOGRAPHIC
EOF

chmod +x run.sh