#!/bin/bash

SCRIPTDIR=$(dirname $(realpath $0))

PASS=""

if [ $# -eq 2 ] ; then
    SRCDIR=$1
    ARCHIVE=$(realpath $2)
    elif [ $# -eq 3 ] ; then
    SRCDIR=$1
    ARCHIVE=$(realpath $2)
    PASS="$3"
else
    echo "$0 <path/to/dir/> <archive.tgz> [<password>]" && exit 0
fi


ARCHIVE=$(realpath $2)
TMPDIR=$(mktemp -d)

echo "SRCDIR: $SRCDIR"
echo "ARCHIVE: $ARCHIVE"
echo "TMPDIR: $TMPDIR"

[ ! -d $SRCDIR ] && echo "Error: source directory not found!" && exit 0
# [ -f $ARCHIVE ] && echo "Error: archive file already exists!" && exit 0

[ -f $ARCHIVE ] && rm -i $ARCHIVE

cp -rf $SRCDIR/* $TMPDIR/

for HOST in $TMPDIR/* ; do
    if [ -d $HOST ] ; then
        echo "HOST: $HOST"
        if [ -z "$PASS" ] ; then
            $SCRIPTDIR/create-disk.sh $HOST $HOST.disk
        else
            $SCRIPTDIR/create-disk-encrypted.sh $HOST $HOST.disk $PASS
        fi
        rm -rf $HOST
    fi
done

( cd $TMPDIR && tar cvzSf archive.tgz * )
mv $TMPDIR/archive.tgz $ARCHIVE
echo "Done!"
