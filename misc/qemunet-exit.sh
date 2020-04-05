#!/bin/bash

[ $# -ne 1 ] && echo "Usage: $0 <path/to/session/dir>" && exit
SESSIONDIR=$1
[ ! -e $SESSIONDIR ] && echo "Error: session directory not found!" && exit 0
LOCK="$SESSIONDIR/lock"

echo "********** Exiting QemuNet Session **********"

# killing all
for pidfile in $SESSIONDIR/*.pid ; do
    PID=$(cat $pidfile)
    disown $PID 2> /dev/null
    echo "killing $pidfile ($PID)"
    kill $PID 2> /dev/null
done

# clean session files
rm -rf $SESSIONDIR/switch
rm -f $SESSIONDIR/*.pid $SESSIONDIR/*.mgmt $SESSIONDIR/*.log
rm -f $LOCK

echo ; echo "=> Terminating all virtual hosts and switches" ; echo

echo "********** Goodbye! **********"


