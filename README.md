QemuNet
=======

QemuNet is a light shell script based on QEMU and VDE to enable easy virtual networking.

### Quick Examples

Launch a single Linux TinyCore VM:
```
$ ./qemunet.sh -i -t images/tinycore/one.topo 
```

Launch a LAN a 4 VMs based on Debian Unstable "minbase":
```
$ ./qemunet.sh -t images/debian/lan4.topo
```

### Demo ###

More examples with complex topology are available in the demo subdirectory.

Fo instance, for the "chain" topology. 
```
$ ./qemunet.sh -x -s demo/chain0.tgz
$ ./qemunet.sh -x -s demo/chain.tgz
```

In the "chain" configuration, the network is well configured in
/mnt/host/start.sh scripts, while in the "chain0" configuration, you
have to do it by yourself.

### Upgrade VM ###

For instance, if you want to install new packages in the "debian"
based image for instance... You can do it easily like this:

```
$ ./qemunet.sh -l debian
```

Then, in the VM, start network and install whatever you want...

```
$ dhclient eth0   # Internet access via Slirp interface of QEMU (no ping)
$ apt-get install package1 package2 ...
$ ...
$ rm /etc/resolv.conf
$ history -c
```

Be careful, all the modifications will be saved definitely in the raw image of the system (ie. images/debian/debian.img).

### Documentation ###

https://gitlab.inria.fr/qemunet/core/wikis/home

---
aurelien.esnard@u-bordeaux.fr

