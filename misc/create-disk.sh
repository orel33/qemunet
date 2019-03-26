#!/bin/bash

[ $# -ne 2 ] && echo "$0 <path/to/input/dir> <disk.img>" && exit

INPUTDIR=$1
DISK=$2
MNTDIR=$(mktemp -d)
SIZE=100M

echo "input dir=$INPUTDIR"
echo "disk=$DISK"
echo "mount dir=$MNTDIR"

[ ! -d $INPUTDIR ] && echo "Error: input directory not found!" && exit 0
[ -f $DISK ] && echo "Error: disk file already exists!" && exit 0

dd if=/dev/zero of=$DISK bs=$SIZE count=1   # empty floppy disk image
/sbin/mkfs.vfat $DISK

# sudo mount -o loop,uid=$UID,gid=$UID $DISK $MNTDIR
sudo mount -o loop $DISK $MNTDIR
sudo cp -v -rf $INPUTDIR/* $MNTDIR
sudo umount $MNTDIR

# eof