#!/bin/bash
QEMUNETDIR="$(realpath $(dirname $0)/..)"
TMUXID="qemunet"
TMUXPIDS=$(tmux list-panes -s -t $TMUXID  -F "#{pane_pid}") # wait cannot be used, for TMUX processes are not children of this bash script!
TMUXTTY=$(tmux list-panes -t $TMUXID:0 -F "#{pane_tty}")
echo > $TMUXTTY
cat $QEMUNETDIR/logo.txt > $TMUXTTY
echo > $TMUXTTY
echo "***********************************************" > $TMUXTTY
echo "TMUX session name: $TMUXID" > $TMUXTTY
echo "Press \"C-b C-c\" to kill the TMUX session." > $TMUXTTY
echo "Hold shift key, to copy/paste with mouse middle-button." > $TMUXTTY
echo "***********************************************" > $TMUXTTY
echo > $TMUXTTY
echo > $TMUXTTY
# TMUX_JOIN
# TMUX_SPLIT
tmux select-window -t $TMUXID:0  # select console (window index 0)
tmux attach-session -t $TMUXID   # tmux in foreground
