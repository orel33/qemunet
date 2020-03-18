#!/bin/bash
SCREENID="qemunet"
echo "=> Cleaning screen session"
screen -ls | grep $SCREENID | cut -d. -f1 | xargs kill
