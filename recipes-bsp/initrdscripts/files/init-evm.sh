#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin

do_mount_fs() {
	grep -q "$1" /proc/filesystems || return
	test -d "$2" || mkdir -p "$2"
	mount -t "$1" "$1" "$2"
}

do_mknod() {
	test -e "$1" || mknod "$1" "$2" "$3" "$4"
}

mkdir -p /proc
mount -t proc proc /proc

do_mount_fs sysfs /sys
do_mount_fs debugfs /sys/kernel/debug
do_mount_fs devtmpfs /dev
do_mount_fs devpts /dev/pts
do_mount_fs tmpfs /dev/shm
do_mount_fs securityfs /sys/kernel/security

mkdir /rootmount
mount -o defaults,i_version -t ext4 /dev/mmcblk2p1 /rootmount

echo rng-caam > /sys/devices/virtual/misc/hw_random/rng_current
echo "kernel:evm" > /sys/bus/platform/devices/blob_gen/modifier
if [ ! -f "/rootmount/evm.blob" ]; then
  echo "Creating new EVM Key"
  dd if=/dev/hwrng of=/sys/bus/platform/devices/blob_gen/payload bs=128 count=1 > /dev/null
  dd if=/sys/bus/platform/devices/blob_gen/blob of=/rootmount/evm.blob > /dev/null
  sync
fi
echo "Loading EVM Key" 
cat /rootmount/evm.blob > /sys/bus/platform/devices/blob_gen/blob
echo "Loading IMA Policy"
cat /etc/ima/ima-policy >> /sys/kernel/security/ima/policy

mkdir -p /run
mkdir -p /var/run

do_mknod /dev/console c 5 1
do_mknod /dev/null c 1 3
do_mknod /dev/zero c 1 5
 
exec switch_root /rootmount /sbin/init
