#!/bin/bash

[ $# -ne 1 ] && echo "$0 <path/to/session/dir>" && exit
SESSIONDIR=$1
[ ! -e $SESSIONDIR ] && echo "Error: session directory not found!" && exit 0
LOCK="$SESSIONDIR/lock"

echo "********** Exiting QemuNet Session **********"

# killing all
for pidfile in $SESSIONDIR/*.pid ; do
    PID=$(cat $pidfile)
    disown $PID 2> /dev/null
    kill $PID 2> /dev/null
done

# FIXME: special clean for tmux & clean
# tmux kill-session -t qemunet &> /dev/null
# TODO: do the same for screen

# if [ "$QEMUDISPLAY" = "tmux" ] ; then $QEMUNETDIR/misc/tmux-exit.sh ; fi
# if [ "$QEMUDISPLAY" = "screen" ] ; then $QEMUNETDIR/misc/screen-exit.sh ; fi

# clean session files
rm -rf $SESSIONDIR/switch
rm -f $SESSIONDIR/*.pid $SESSIONDIR/*.mgmt $SESSIONDIR/*.log
rm -f $LOCK

echo ; echo "=> Terminating all virtual hosts and switches" ; echo

echo "********** Goodbye! **********"


