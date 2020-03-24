#!/bin/bash
QEMUNETDIR="$(realpath $(dirname $0)/..)"
TMUXID="qemunet"

# check if session is alive...
tmux has-session -t $TMUXID &> /dev/null
[ $? -ne 1 ] && echo "ERROR: TMUX session \"$TMUXID\" already available!" && exit 1

tmux start-server
tmux new-session -d -s $TMUXID -n console bash # tmux console #TODO: how to remove this console?

tmux set-option -t $TMUXID -g default-shell /bin/bash
tmux set-option -t $TMUXID -g mouse on # enable to select panes/windows  with mouse (howewer, hold shift key, to copy/paste with mouse)
# tmux set-option -g prefix C-b
# tmux bind-key C-c kill-session  # press "C-b C-c" to kill session!
# tmux bind-key C-c kill-session  # press "C-b C-c" to kill session!
# tmux bind-key x kill-server  # press "C-b x" to kill server!
tmux bind-key x kill-session  # press "C-b x" to kill current session!

# tmux set-window-option -g window-status-current-bg red
tmux set-window-option -g aggressive-resize on
# tmux set-option -g allow-rename off
tmux set-option -g status-left ''
tmux set-option -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m/%Y #[fg=colour233,bg=colour245,bold] %H:%M:%S '
tmux bind P select-window -t :0 \\\; send-keys "$QEMUNETDIR/misc/tmux-panes.sh" Enter \\\; select-window -t :1   # one single window with multiple panes
tmux bind W select-window -t :0 \\\; send-keys "$QEMUNETDIR/misc/tmux-windows.sh" Enter \\\; select-window -t :1 # multiple windows

# start switch in different session...
# tmux new-session -d -s switch -n console bash # tmux console #TODO: how to remove this console?
