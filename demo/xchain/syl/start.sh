#!/bin/sh
hostname syl
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
ifconfig eth0 147.210.21.2/24
route add default gw 147.210.21.1

cat <<EOF > /etc/resolv.conf
nameserver 10.0.0.1
search qemunet.org
EOF


