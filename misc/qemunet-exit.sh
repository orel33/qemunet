#!/bin/bash
QEMUNETDIR="$(realpath $(dirname $0)/..)"

[ $# -ne 2 ] && echo "Usage: $0 <session_id> <path/to/session/dir>" && exit 1
SESSIONID=$1
SESSIONDIR=$2
[ -z $SESSIONID ] && echo "Error: session ID not found!" && exit 1
[ ! -e $SESSIONDIR ] && echo "Error: session directory not found!" && exit 1

LOCK="$SESSIONDIR/lock"

echo "********** Exiting QemuNet Session **********"

# killing all
shopt -s nullglob # a pattern that matches nothing "disappears"
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

# TODO: only if required...
$QEMUNETDIR/misc/tmux-exit.sh $SESSIONID
$QEMUNETDIR/misc/screen-exit.sh $SESSIONID

echo "********** Goodbye! **********"


