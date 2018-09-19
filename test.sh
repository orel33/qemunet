#!/bin/bash -x
IMGDIR="/home/orel/Documents/Virt/qemunet/qemunet/images"
IMG="$IMGDIR/debian10.img"
KERNEL="$IMGDIR/debian10.vmlinuz"
INITRD="$IMGDIR/debian10.initrd"
# SESSIONDIR="/tmp/qemu-test"
SESSIONDIR=$(mktemp -u -d /tmp/qemu-test-XXXXXX)
mkdir -p $SESSIONDIR
ln -T -sf $SESSIONDIR session

echo "session directory: $SESSIONDIR"

TTY=$(tty)
reset # reset terminal

### BASIC OPTIONS ###

BASIC="-name test -rtc base=localtime -enable-kvm -m 512 -hda $SESSIONDIR/my.qcow2"

### DISPLAY ###

# DISPLAY="-curses"    # buggy?
# DISPLAY="-display none"
# DISPLAY="-display gtk" # gtk initialization failed
# DISPLAY="-display sdl" # sdl not available
DISPLAY="-nographic"   # ok (no graphic display + redirect on stdio)

### MONITOR ###

# MONITOR="-monitor unix:$SESSIONDIR/monitor.sock,server,nowait"
# MONITOR="-monitor stdio" # ?
# MONITOR="-monitor $TTY" # redirect Qemu Monitor to the current PTY

### SOCKET ###

# https://web.archive.org/web/20171221004914/http://nairobi-embedded.org:80/qemu_serial_terminal_redirection.html
# https://web.archive.org/web/20171227193804/http://nairobi-embedded.org:80/qemu_serial_port_system_console.html
# https://web.archive.org/web/20180104171638/http://nairobi-embedded.org/qemu_monitor_console.html
# to connect Unix socket, run: $ socat stdin,raw,echo=0,escape=0x11 unix-connect:session/serial.sock

# SOCKET="-serial unix:$SESSIONDIR/serial.sock,server,nowait" # server mode (unix)
# SOCKET="-serial unix:$SESSIONDIR/serial.sock,server" # wait client connection
# SOCKET="-chardev socket,host=127.0.0.1,port=7777,id=s0,server -device isa-serial,chardev=s0" # server mode (tcp, connect with "netcat localhost 7777")
# SOCKET="-serial tcp:localhost:7777"  # client mode (tcp, launch tcp server with "netcat -l 7777" before)

### SHARE ####

# SHARE="-fsdev local,id=share0,path=$SESSIONDIR,security_model=mapped -device virtio-9p-pci,fsdev=share0,mount_tag=host"

### BOOT ###
BOOTARG="root=/dev/sda1 rw net.ifnames=0 console=ttyS0 console=tty0"
BOOT="-kernel $KERNEL -initrd $INITRD -append \"$BOOTARG\""

####################### RUN QEMU #######################

qemu-img create -q -b $IMG -f qcow2 $SESSIONDIR/my.qcow2 # create qcow image based on raw image

CMD="qemu-system-x86_64 $BASIC $BOOT $SHARE $MONITOR $SOCKET $DISPLAY" # too long variable?
# echo "$CMD"

# solution 0 (fail because double-quote expansion in -append option)
# qemu-system-x86_64 $BASIC $BOOT $SHARE $MONITOR $SOCKET $DISPLAY & 

# solution 1
# bash -c "$CMD"

# solution 2
# export CMD
# bash -c 'eval $CMD' # my trick

# solution 3
eval "$CMD"

# For Qemu command in background (&)
# PID=$!
# echo "qemu pid: $PID"
# wait $PID

# EOF
