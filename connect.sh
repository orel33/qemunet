#!/bin/bash

### CHECK SOCAT COMMAND ####
SOCAT="socat"
if ! [ -x  "$(type -P $SOCAT)" ] ; then
    echo "ERROR: $SOCAT not found !"
    exit
fi

### USAGE ###

USAGE() {
    echo "Connect a QemuNet VM console using Unix Socket."
    echo "\$ $0 <sessiondir> <hostname>"
    exit
}


### CHECK ARGS ###
SESSIONDIR="$1"
HOST="$2"
if ! [ $# -eq 2 ] ; then USAGE ; fi

# socat stdin,raw,echo=0,escape=0x11 unix-connect:$SESSIONDIR/<host>.monitor"
# socat stdin,raw,echo=0,escape=0x11 unix-connect:$SESSIONDIR/<host>.sock"

# what about using rlwrap?

# check unix socket file
SOCKET="$SESSIONDIR/$HOST.sock"

if ! [ -S "$SOCKET" ] ; then echo "ERROR: file $SOCKET is missing or is not a valid Unix socket!" ; exit ; fi

OPTIONS="stdin,raw,echo=0,escape=0x11"
$SOCAT $OPTIONS unix-connect:$SOCKET