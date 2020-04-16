#!/bin/bash

[ $# -ne 1 ] && echo "$0 <password>" && exit

PASS="$1"

ALL=$(find . -mindepth 1 -maxdepth 1 -type d)

for DIR in $ALL ; do
    HACK="$DIR.tgz"
    [ -f "$HACK" ] && rm -i $HACK
    echo "########## Generate $HACK ##########"
    ../misc/generate.sh $DIR $HACK $PASS
done
