#!/bin/bash
QEMUNETDIR="$(realpath $(dirname $0)/..)"
TMUXID="qemunet"

# check if session is alive...
tmux has-session -t $TMUXID &> /dev/null
[ $? -ne 0 ] && echo "ERROR: no TMUX session \"$TMUXID\"!" && exit 1

# TMUXPIDS=$(tmux list-panes -s -t $TMUXID  -F "#{pane_pid}") # wait cannot be used, for TMUX processes are not children of this bash script!
TMUXTTY=$(tmux list-panes -t $TMUXID:0 -F "#{pane_tty}")
echo "=> attach TMUX session name: $TMUXID"
# echo > $TMUXTTY
# cat $QEMUNETDIR/logo.txt > $TMUXTTY
# echo > $TMUXTTY
# echo "***********************************************" > $TMUXTTY
# echo "TMUX session name: $TMUXID" > $TMUXTTY
# echo -e "\r\nPress \"C-b C-c\" to kill the TMUX session." > $TMUXTTY
# echo -e "Press \"C-b d\" to detach the TMUX session.\n" > $TMUXTTY
# echo "Hold shift key, to copy/paste with mouse middle-button." > $TMUXTTY
# echo "***********************************************" > $TMUXTTY
# echo > $TMUXTTY
# echo > $TMUXTTY
# TMUX_JOIN
# TMUX_SPLIT
tmux select-window -t $TMUXID:0  # select console (window index 0)
tmux attach-session -t $TMUXID   # tmux in foreground

# tmux send-keys -t $TMUXID "sleep 1 ; clear ; echo 'Hello World'" ENTER

