#!/bin/bash
[ $# -ne 1 ] && echo "Usage: $0 <session_id>" && exit 1
SESSIONID=$1
[ -z $SESSIONID ] && echo "Error: session ID not found!" && exit 1

# SCREENID="$SESSIONID"
SCREENID="qemunet"
screen -ls qemunet &> /dev/null
if [ $? -eq 0 ] ; then
    echo "=> Cleaning screen session: $SESSIONID"
    screen -ls qemunet | grep $SCREENID | cut -d. -f1 | xargs kill &> /dev/null
fi