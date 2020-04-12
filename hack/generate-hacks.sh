#!/bin/bash

for DIR in $(find . -mindepth 1 -maxdepth 1 -type d) ; do    
    HACK="$DIR.tgz"
    rm -f $HACK
    echo "########## Generate $HACK ##########" 
    ../misc/generate.sh $DIR $HACK 
done
