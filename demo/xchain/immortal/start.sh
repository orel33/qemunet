#!/bin/sh
hostname immortal
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
ifconfig eth0 192.168.0.254/24
ifconfig eth1 10.0.0.1/24
echo 1 > /proc/sys/net/ipv4/ip_forward
route add default gw 10.0.0.2

cat <<EOF > /etc/resolv.conf
nameserver 10.0.0.1
search qemunet.org
EOF

### DHCP Sever ###

cat <<EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
option domain-name "qemunet.org";                                             
option domain-name-servers 10.0.0.1;
subnet 192.168.0.0 netmask 255.255.255.0 {
    range 192.168.0.10 192.168.0.20;
    option broadcast-address 192.168.0.255;
    option routers 192.168.0.254;
    option subnet-mask 255.255.255.0;
    # win10
    host opeth {
      hardware ethernet AA:AA:AA:AA:03:00;
      fixed-address 192.168.0.10;
    }
    # debian10x
    host nile { 
      hardware ethernet AA:AA:AA:AA:04:00;
      fixed-address 192.168.0.11;
  }
}
EOF

cat <<EOF > /etc/default/isc-dhcp-server 
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

service isc-dhcp-server start

### DNSMASQ Sever ###

cat <<EOF > /etc/dnsmasq.conf
domain=qemunet.org
interface=eth0
interface=eth1
no-hosts
addn-hosts=/etc/dnsmasq.hosts
EOF

cat <<EOF > /etc/dnsmasq.hosts
192.168.0.10 opeth.qemunet.org
192.168.0.11 nile.qemunet.org
192.168.0.254 immortal.qemunet.org
10.0.0.1 immortal.qemunet.org
10.0.0.2 grave.qemunet.org
147.210.21.1 grave.qemunet.org
147.210.21.2 syl.qemunet.org
EOF

service dnsmasq start


