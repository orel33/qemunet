#!/bin/bash
echo "=> convert an session archive with host directories to an archive with disk images..."
[ $# -ne 1 ] && echo "$0 <path/to/archive.tgz>" && exit

SCRIPTDIR=$(dirname $(realpath $0))
ARCHIVE=$1
ARCHIVE=$(realpath $ARCHIVE)
BACKUP="$ARCHIVE.bak"
TMP=$(mktemp -d)
echo "TMP: $TMP"
echo "ARCHIVE: $ARCHIVE"
echo "BACKUP: $BACKUP"
cp -i $ARCHIVE $BACKUP

tar xzf $ARCHIVE -C $TMP

for HOST in $TMP/* ; do
    if [ -d $HOST ] ; then
        echo "HOST: $HOST"
        $SCRIPTDIR/misc/create-disk.sh $HOST $HOST.disk
        rm -rf $HOST
    fi
done

rm $ARCHIVE
( cd $TMP && tar cvzSf $ARCHIVE * )
echo "Converted archive: $ARCHIVE"