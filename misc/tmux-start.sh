#!/bin/bash
QEMUNETDIR="$(realpath $(dirname $0)/..)"

[ $# -ne 2 ] && echo "Usage: $0 <session_id> <path/to/session/dir>" && exit 1
SESSIONID=$1
SESSIONDIR=$2
[ -z $SESSIONID ] && echo "Error: session ID not found!" && exit 1
[ ! -e $SESSIONDIR ] && echo "Error: session directory not found!" && exit 1

# TMUXID="qemunet"
TMUXID="$SESSIONID"
TMUXTIMEOUT="4h"

# check if a tmux session "qemunet*" is already alive...
# tmux has-session -t $TMUXID &> /dev/null
tmux has-session -t qemunet &> /dev/null
if [ $? -ne 1 ] ; then
    echo "ERROR: a TMUX session for qemunet is already available!"
    tmux ls
    echo "=> either attach (\"tmux a\") or kill session (\"tmux kill-session\")"
    exit 1
fi

tmux start-server
tmux new-session -d -s $TMUXID -n console bash # tmux console #TODO: how to remove this console?

TMUXEXITCMD="sleep $TMUXTIMEOUT ; $QEMUNETDIR/misc/qemunet-exit.sh $SESSIONID $SESSIONDIR"
echo "=> tmux exit command: $TMUXEXITCMD"
tmux run-shell -t $TMUXID -b "$TMUXEXITCMD"  # run as a background command in tmux...

tmux set-option -t $TMUXID -g default-shell /bin/bash
tmux set-option -t $TMUXID -g mouse on # enable to select panes/windows  with mouse (howewer, hold shift key, to copy/paste with mouse)
tmux set-option -g prefix C-b
tmux unbind-key x
tmux bind-key x run-shell "$QEMUNETDIR/misc/qemunet-exit.sh $SESSIONID $SESSIONDIR" \\\; kill-session  # press "C-b x" to kill current session!
tmux unbind-key X
tmux bind-key X kill-session  # press "C-b x" to kill session!
# tmux bind-key x send-keys "$QEMUNETDIR/misc/qemunet-exit.sh $SESSIONDIR" Enter \\\; kill-session  # press "C-b x" to kill current session!

# tmux set-window-option -g window-status-current-bg red
tmux set-window-option -g aggressive-resize on
# tmux set-option -g allow-rename off
tmux set-option -g status-left ''
tmux set-option -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m/%Y #[fg=colour233,bg=colour245,bold] %H:%M:%S '
# tmux bind P select-window -t :0 \\\; send-keys "$QEMUNETDIR/misc/tmux-panes.sh" Enter \\\; select-window -t :1   # one single window with multiple panes
# tmux bind W select-window -t :0 \\\; send-keys "$QEMUNETDIR/misc/tmux-windows.sh" Enter \\\; select-window -t :1 # multiple windows

# start switch in different session...
# tmux new-session -d -s switch -n console bash # tmux console #TODO: how to remove this console?
