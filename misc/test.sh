#!/bin/bash
IMGDIR="$PWD/images"
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

### BASIC OPTIONS ###

BASIC="-name test -rtc base=localtime -enable-kvm -m 512 -hda $SESSIONDIR/my.qcow2"

### FLOPPY ###

# ./misc/create-floppy.sh misc/data $SESSIONDIR/floppy.img
# FLOPPY="-fda $SESSIONDIR/floppy.img"
# FLOPPY="-hdb $SESSIONDIR/floppy.img"
# FLOPPY="-hdb $SESSIONDIR/floppy.img"
# FLOPPY="-hdb fat:rw:/tmp/pouet" # it works, but it will be probably soon deprecated (VVFAT)

### DISPLAY ###

# DISPLAY="-display none"
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
# https://www.linux-kvm.org/page/9p_virtio
# SHARE="-fsdev local,id=share0,path=$SESSIONDIR,security_model=mapped -device virtio-9p-pci,fsdev=share0,mount_tag=host"

# sudo mount -t 9p -o trans=virtio host /mnt/host

### BOOT ###
# BOOT="-kernel $KERNEL -initrd $INITRD"
# BOOT="-kernel $KERNEL -initrd $INITRD -append \"root=/dev/sda1 rw net.ifnames=0 console=ttyS0 console=tty0\""
BOOT="-kernel $KERNEL -initrd $INITRD -append 'root=/dev/sda1 rw net.ifnames=0 console=ttyS0 console=tty0'"

####################### RUN QEMU #######################

# create qcow image based on raw image, else use qcow2 if available
[ ! -f "$SESSIONDIR/my.qcow2" ] && qemu-img create -q -b $IMG -f qcow2 $SESSIONDIR/my.qcow2 

CMD="qemu-system-x86_64 $BASIC $BOOT $FLOPPY $SHARE $MONITOR $SOCKET $DISPLAY"

bash -c "echo $CMD"
bash -c "${CMD[@]}"

# EOF
