#!/bin/bash
TMUXID="qemunet"
tmux kill-session -t $TMUXID &> /dev/null
