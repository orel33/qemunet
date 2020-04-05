#!/bin/bash
TMUXID="qemunet"
echo "=> Cleaning tmux session"
tmux kill-session -t $TMUXID &> /dev/null
