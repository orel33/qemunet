#!/bin/bash

[ $# -ne 2 ] && echo "$0 <path/to/dir/> <archive.tgz>" && exit 0

SCRIPTDIR=$(dirname $(realpath $0))
SRCDIR=$1
ARCHIVE=$(realpath $2)
TMPDIR=$(mktemp -d)

echo "SRCDIR: $SRCDIR"
echo "ARCHIVE: $ARCHIVE"
echo "TMPDIR: $TMPDIR"

[ ! -d $SRCDIR ] && echo "Error: source directory not found!" && exit 0
[ -f $ARCHIVE ] && echo "Error: archive file already exists!" && exit 0

cp -rf $SRCDIR/* $TMPDIR/

for HOST in $TMPDIR/* ; do
    if [ -d $HOST ] ; then
	echo "HOST: $HOST"
	$SCRIPTDIR/create-disk.sh $HOST $HOST.disk
	rm -rf $HOST
    fi
done

( cd $TMPDIR && tar cvzSf archive.tgz * )
mv $TMPDIR/archive.tgz $ARCHIVE
echo "Done!"
