#!/bin/sh
hostname nile
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
dhclient eth0


