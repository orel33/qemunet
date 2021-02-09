#!/bin/bash

[ $# -ne 2 ] && echo "$0 <disk.img> <disk dir>" && exit 1

DISK=$1
DISKDIR=$2
[ ! -f $DISK ] && echo "Error: disk file not found!" && exit 1
[ ! -d "$DISKDIR" ] && echo "Error: target <disk dir> not found!" && exit 1
MNTDIR=$(mktemp -d)

echo "DISK=$DISK"
echo "DISKDIR=$DISKDIR"
echo "MNTDIR=$MNTDIR"

sudo mount -o loop,uid=$UID,gid=$UID $DISK $MNTDIR
sudo cp -v -rf $MNTDIR/* $DISKDIR/
sudo umount $MNTDIR

# eof
