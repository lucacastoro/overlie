#!/bin/bash

set -e
set -x

user=$USER

dir=$(mktemp -d)

echo "temporary directory: $dir"

cleanup() {
  rm -rf $dir
}

trap cleanup EXIT

upper=$dir/upper
work=$dir/work
root=$dir/root

mkdir $upper $work $root

#
# qui va la gestione dei namespace
# vedi http://man7.org/linux/man-pages/man7/user_namespaces.7.html
#

sudo mount -t overlay -o lowerdir=/,upperdir=$upper,workdir=$work none $root
sudo mount --bind /proc $root/proc
sudo mount --bind /sys $root/sys
sudo mount --bind /run $root/run
sudo mount --bind /dev $root/dev

sudo chroot $root

sudo umount $root/dev
sudo umount $root/run
sudo umount $root/sys
sudo umount $root/proc
sudo umount $root
