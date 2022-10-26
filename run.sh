#!/bin/sh
LAN=ledetap0
# create tap interface which will be connected to OpenWrt LAN NIC
ip tuntap add mode tap $LAN
ip link set dev $LAN up
# configure interface with static ip to avoid overlapping routes
ip addr add 192.168.1.101/24 dev $LAN
qemu-system-arm \
-M virt-2.7 \
-m 256 \
-device virtio-net-pci,netdev=lan \
-netdev tap,id=lan,ifname=$LAN,script=no,downscript=no \
-device virtio-net-pci,netdev=wan \
-netdev user,id=wan \
-kernel '/home/user/script/result/v19.07.4-bcm53xx--1/armvirt/32/openwrt-armvirt-32-zImage' \
-hda '/home/user/script/result/v19.07.4-bcm53xx--1/armvirt/32/openwrt-armvirt-32-root.ext4' \
-append root=/dev/vda \
-nographic
# cleanup, delete tap interface created earlier
ip addr flush dev $LAN
ip link set dev $LAN down
ip tuntap del mode tap dev $LAN
