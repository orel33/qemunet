#!/bin/bash
TMUXID="qemunet"
screen -ls | grep $TMUXID | cut -d. -f1 | xargs kill
