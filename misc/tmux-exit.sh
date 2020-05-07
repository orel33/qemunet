#!/bin/bash
[ $# -ne 1 ] && echo "Usage: $0 <session_id>" && exit 1
SESSIONID=$1
[ -z $SESSIONID ] && echo "Error: session ID not found!" && exit 1

# TMUXID="qemunet"
TMUXID="$SESSIONID"
tmux has-session -t $TMUXID &> /dev/null
if [ $? -eq 0 ] ; then
    echo "=> Cleaning tmux session: $SESSIONID"
    tmux kill-session -t $TMUXID &> /dev/null
fi
