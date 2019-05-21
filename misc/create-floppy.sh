#!/bin/bash

# sudo apt-get install fuse fuseext2

[ $# -ne 2 ] && echo "$0 <path/to/input/dir> <floppy>" && exit

INPUTDIR=$1
FLOPPY=$2
MNTDIR=$(mktemp -d)
SIZE=1440K
COUNT=1

echo "input dir=$INPUTDIR"
echo "floppy=$FLOPPY"
echo "mount dir=$MNTDIR"

[ ! -d $INPUTDIR ] && echo "Error: input directory not found!" && exit 0
[ -f $FLOPPY ] && echo "Error: floppy file already exists!" && exit 0

dd if=/dev/zero of=$FLOPPY bs=$SIZE count=$COUNT # empty floppy disk image
sudo mkfs.ext2 $FLOPPY                           # format ext2 filesystem (root privilege)

fuseext2 $FLOPPY $MNTDIR -o rw+
cp -v -rf $INPUTDIR/* $MNTDIR
fusermount -u $MNTDIR

# eof