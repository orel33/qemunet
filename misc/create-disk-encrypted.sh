#!/bin/bash -x

[ $# -ne 3 ] && echo "$0 <path/to/input/dir> <disk.img> <password>" && exit

INPUTDIR=$1
DISK=$2
PASS=$3
MNTDIR=$(mktemp -d)
SIZE=100M

echo "input dir=$INPUTDIR"
echo "disk=$DISK"
echo "mount dir=$MNTDIR"

rm -i $DISK

[ ! -d $INPUTDIR ] && echo "Error: input directory not found!" && exit 0
[ -f $DISK ] && echo "Error: disk file already exists!" && exit 0


dd if=/dev/zero of=$DISK bs=$SIZE count=1   # empty floppy disk image
/sbin/mkfs.vfat $DISK

# chmod 777 $MNTDIR
# ls -ld $MNTDIR
# sudo mount -o loop $DISK $MNTDIR
sudo mount -o loop,uid=$UID,gid=$UID $DISK $MNTDIR
# chmod 777 $MNTDIR
ls -ld $MNTDIR

export PASS
( cd $INPUTDIR ; tar cvf $MNTDIR/$DISK.tar * )
openssl enc -in $MNTDIR/$DISK.tar -out $MNTDIR/$DISK.tar.enc -pass env:PASS
# rm -f $MNTDIR/$DISK.tar
sudo umount $MNTDIR

# rm -rf $MNDIR

# eof