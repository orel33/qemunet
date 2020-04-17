#!/bin/bash

[ $# -ne 2 -a $# -ne 1 ] && echo "$0 <disk.img> [<path/to/dir>]" && exit 0

DISK=$1
DISKDIR=$2
[ -z "$DISKDIR" ] && DISKDIR=$(mktemp -d)

echo "disk=$DISK"
echo "target disk dir=$DISKDIR"

# [ ! -d $DISKDIR ] && echo "Error: target disk directory not found!" && exit 0
[ ! -d $DISKDIR ] && mkdir -p $DISKDIR
[ ! -f $DISK ] && echo "Error: disk file not found!" && exit 0

sudo mount -o loop,uid=$UID,gid=$UID $DISK $DISKDIR
# sudo mount -o loop $DISK $DISKDIR

# sudo cp -v -rf $INPUTDIR/* $MNTDIR

echo "Warning! Don't forget to umount $DISKDIR..."

# eof
