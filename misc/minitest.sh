#!/bin/bash
IMGDIR="/net/ens/qemunet/images"
IMG="$IMGDIR/debian10.img"
KERNEL="$IMGDIR/debian10.vmlinuz"
INITRD="$IMGDIR/debian10.initrd"
SESSIONDIR="/tmp/qemu-test"
# SESSIONDIR=$(mktemp -u -d /tmp/qemu-test-XXXXXX)
mkdir -p $SESSIONDIR
ln -T -sf $SESSIONDIR session

echo "session directory: $SESSIONDIR"

TTY=$(tty)
reset # reset terminal

### INPUT ARGS ###

NAME="$1"

### BASIC OPTIONS ###

DISK="$SESSIONDIR/$NAME.qcow2"
BASIC="-name $NAME -rtc base=localtime -enable-kvm -m 200 -hda $DISK"
DISPLAY="-nographic"   # ok (no graphic display + redirect on stdio)

### BOOT ###
BOOT="-kernel $KERNEL -initrd $INITRD -append 'root=/dev/sda1 rw net.ifnames=0 console=ttyS0 console=tty0'"

####################### RUN QEMU #######################

# create qcow image based on raw image, else use qcow2 if available
[ ! -f "$DISK" ] && qemu-img create -q -b "$IMG" -f qcow2 "$DISK"
CMD="qemu-system-x86_64 $BASIC $BOOT $DISPLAY"

# bash -c "echo $CMD"
bash -c "${CMD[@]}"

# EOF
