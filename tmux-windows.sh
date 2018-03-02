#!/bin/sh
NBPANES=$(tmux list-panes -t :1 -F "#{pane_index}" | wc -l)
for PANE in $(seq 2 $NBPANES) ; do tmux break-pane -d -s 1.0 ; done

