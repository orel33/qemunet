#!/bin/bash
IMGDIR="/home/orel/Documents/Virt/qemunet/qemunet/images/"
IMG="$IMGDIR/debian10.img"
KERNEL="$IMGDIR/debian10.vmlinuz"
INITRD="$IMGDIR/debian10.initrd"
SESSIONDIR="/tmp/qemu-test"

mkdir -p $SESSIONDIR

qemu-img create -q -b $IMG -f qcow2 $SESSIONDIR/my.qcow2

qemu-system-x86_64 -name single -rtc base=localtime -enable-kvm -m 512 -hda $SESSIONDIR/my.qcow2 \
  -monitor unix:$SESSIONDIR/monitor.sock,server,nowait -serial unix:$SESSIONDIR/serial.sock,server,nowait \
  -fsdev local,id=share0,path=$SESSIONDIR,security_model=mapped -device virtio-9p-pci,fsdev=share0,mount_tag=host \
  -kernel $KERNEL -initrd $INITRD -append "root=/dev/sda1 rw net.ifnames=0 console=ttyS0" \
  -nographic 

echo
echo "run: \$ socat stdin,raw,echo=0,escape=0x11 unix-connect:$SESSIONDIR/serial.sock"

# rm -rf $SESSIONDIR