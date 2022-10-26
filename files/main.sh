#!/bin/bash

# Cloning openwrt from github
git config --global http.sslverify false
git clone https://github.com/openwrt/openwrt.git openwrt

# Checkout version and download packages
cd openwrt
git checkout $VERSION ./include/kernel-defaults.mk
git checkout $VERSION
./scripts/feeds update -a
./scripts/feeds install -a

# Force kernel patches
if [ $VERSION \< "v19.07.0" ]; then
    cp ../kernel-git-force-patches-old.patch .
    patch ./include/kernel-defaults.mk  < kernel-git-force-patches-old.patch
else
    cp ../kernel-git-force-patches.patch .
    patch ./include/kernel-defaults.mk  < kernel-git-force-patches.patch
fi

# Generating emulation target/subtarget openwrt .config
# and parsing default packages
echo "CONFIG_TARGET_$TARGET=y" > .config
if [ $SUBTARGET != -1 ]; then
    echo "CONFIG_TARGET_$TARGET_$SUBTARGET=y" >> .config    
fi

make defconfig
if [ $SUBTARGET == -1 ]; then
    SUBTARGET=`grep "CONFIG_TARGET_SUBTARGET" .config | cut -d "=" -f 2 | tr -d '[="=]'`
    echo $SUBTARGET > subtarget.txt
fi

grep "CONFIG_PACKAGE" < .config > $TARGET.config
sed -i '/#/d' $TARGET.config

# Generating armvirt/x86 openwrt .config with parsed packages
# and custom kernel if it's needed
echo "CONFIG_TARGET_$ARCH=y" > .config
if [ $KERNEL_GIT != -1 ]; then
    echo "CONFIG_DEVEL=y" >> .config
    echo "CONFIG_KERNEL_GIT_CLONE_URI=\"$KERNEL_GIT\"" >> .config
    echo "CONFIG_KERNEL_GIT_LOCAL_REPOSITORY=\"\"" >> .config 
    echo "CONFIG_KERNEL_GIT_MIRROR_HASH=\"\"" >> .config

    if [ $KERNEL_GIT_REF != -1 ]; then
        echo "CONFIG_KERNEL_GIT_REF=\"$KERNEL_GIT_REF\"" >> .config
    fi
fi

cat $TARGET.config >> .config

# Adding web interface
if [ $LUCI == "y" ]; then
    cat /script/luci.config >> .config
fi

# Extending config
make defconfig

# Clean previous compilation results
make clean

# Compilation
echo "Using $JOBS jobs"
make -j$JOBS V=s