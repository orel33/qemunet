#!/bin/sh
hostname grave
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
ifconfig eth0 10.0.0.2/24
ifconfig eth1 147.210.21.1/24
echo 1 > /proc/sys/net/ipv4/ip_forward
route add default gw 10.0.0.1

cat <<EOF > /etc/resolv.conf
nameserver 10.0.0.1
search qemunet.org
EOF

