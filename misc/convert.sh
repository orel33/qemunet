#!/bin/bash

ARCHIVE=$1
ARCHIVE=$(realpath $ARCHIVE)
TMP=$(mktemp -d)
echo "TMP: $TMP"
echo "ARCHIVE: $ARCHIVE"



tar xzf $ARCHIVE -C $TMP

for HOST in $TMP/* ; do
    if [ -d $HOST ] ; then
	echo "HOST: $HOST"
	./misc/create-disk.sh $HOST $HOST.disk
	rm -rf $HOST
    fi
done

rm $ARCHIVE
( cd $TMP && tar cvzSf $ARCHIVE * )
