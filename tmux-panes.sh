#!/bin/bash
NBWINS=$(tmux list-windows -F "#{window_index}" | wc -l)
NBWINS=$(expr $NBWINS - 1)
for WIN in $(seq 2 $NBWINS) ; do tmux join -d -s $WIN -t 1 ; done
tmux select-layout -t:1 tiled        
