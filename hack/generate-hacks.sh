#!/bin/bash

ALL=$(find . -mindepth 1 -maxdepth 1 -type d)

for DIR in $ALL ; do    
    HACK="$DIR.tgz"
    rm -f $HACK
    echo "########## Generate $HACK ##########" 
    ../misc/generate.sh $DIR $HACK 
done
