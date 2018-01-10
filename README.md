QemuNet
=======

*QemuNet is a light shell script based on QEMU and VDE to enable easy virtual networking.* 

### Requirements ###

First of all, the QemuNet script is written in *Bash* version greater than or equal to 4. Then, you can install all the QemuNet dependencies in a Debian-like OS, as follow: 

```
$ sudo apt-get install qemu qemu-kvm vde2 libattr1 libvirt0 socat rlwrap wget virt-manager
```

In practice, *QemuNet* requires QEMU (qemu-system-x86_64) with VDE and KVM supports enabled and with a *version greater than or equal to 2.1*!!! Check it:

```
$ qemu-system-x86_64 --version  
```

By default *QemuNet* use the KVM support, to speed up the QEMU execution. To check if KVM is well installed, you can launch the following commmand. 

```
$ virt-host-validate qemu
```

If the KVM test fails, we recommand you to solve this problem before to use *QemuNet*. The -K option provided by *qemunet.sh* disables KVM, but it will be really too slow. For further details on KVM: https://wiki.archlinux.org/index.php/KVM

### Download & Install ###

QemuNet is a free software distributed under the terms of the GNU General Public License (GPL) and it is available for download at [Inria GitLab](https://gitlab.inria.fr/qemunet). 

Let's download it:

```
  $ git clone https://gitlab.inria.fr/qemunet/core.git qemunet
```

The main QemuNet files are described below:

```
qemunet
  ├── demo/         <-- some basic examples of topology 
  ├── images/       <-- default empty directory to store system images
  ├── qemunet.cfg   <-- the default qemunet configuration file
  ├── qemunet.sh    <-- main qemunet script
  └── README.md     <-- this file
```

By default, the *images* directory is empty. The default system images (described in *qemunet.cfg*) will be automatically download by the QemuNet script at first use. The default *QemuNet* images are available on [Inria GitLab](https://gitlab.inria.fr/qemunet/images).

### Test ###

Now, you can launch the following tests, that are  based on a *Linux TinyCore* system or a *Linux Debian* system. 

```
$ ./qemunet.sh -t demo/tinycore.topo
$ ./qemunet.sh -t demo/single.topo  
```

At this point, if you get some errors, go to the *Configuration" section.

### Let's start with a basic LAN ###

You will find several examples in the *demo* subdirectory. But, let's start with a basic LAN topology.

First, you need to prepare a virtual topology file, as for example [demo/lan.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/lan.topo). It describes a LAN with 4 *debian* Virtual Machines (VM), named *host1* to *host4* and one Virtual Switch (VS) named *s1*. The *debian* system must refer to a valid system in the *QemuNet* configuration file [qemunet.cfg](https://gitlab.inria.fr/qemunet/core/raw/master/qemunet.cfg).

```
# SWICTH switchname
SWITCH s1
# HOST sysname hostname switchname0 switchname1 ...
HOST debian host1 s1
HOST debian host2 s1
HOST debian host3 s1
HOST debian host4 s1
```

Here is an example of the *QemuNet* configuration file *qemunet.cfg*. It requires to provide a valid Debian image for QEMU. Optionnaly, you will need to extract the kernel files (initrd & vmlinuz) from this image, as explained later. 

```
IMGDIR="/absolute/path/to/raw/system/images"
SYS[debian]="linux"
QEMUOPT[debian]="-localtime -m 512"
FS[debian]="$IMGDIR/debian/debian.img"
KERNEL[debian]="$IMGDIR/debian/debian.vmlinuz"
INITRD[debian]="$IMGDIR/debian/debian.initrd"
URL[debian]="https://gitlab.inria.fr/qemunet/images/raw/master/debian.tgz"
```

Following, you can launch your Virtual Network (VN). All the current session files are provided in the *session* directory, that is linked to a unique directory in /tmp. 

```
$ ./qemunet.sh -t images/debian/lan.topo
```
Once you have finish your work, halt all machines properly with "poweroff" command. Thus, you are sure that all VM disks are up-to-date. 

If you want to restore your session from the current session directory, you can simply type:

```
$ ./qemunet.sh -S session
```

In order to save your session, you need to save all session files in a tgz archive. 

```
$ cd session ; tar cvzf lan.tgz * ; cd ..
```

So, you will be able to restore your session later as follow:

```
$ ./qemunet.sh -s lan.tgz
```
  
For instance, if you modify the system files of the VM *host1*, those modifications will not modify directly the raw system image *debian.img* (provided in *qemunet.cfg*), but it will store it the file *session/host1.qcow2*.

In addition, we use a startup script to load a user-defined script "/mnt/host/start.sh", that is stored in the file *session/<hostname>/start.sh*. It is a flexible way to setup each VM without modifying the raw system image or using the qcow2 files (that depends on the raw image). For instance, you can start the LAN demo with all IPs and hostnames well configured:

```
$ ./qemunet.sh -x -s demo/lan.tgz
```

### Other Examples ###

Other samples are available in the [demo](https://gitlab.inria.fr/qemunet/core/tree/master/demo) subdirectory, as for instance:

  * [demo/single.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/single.topo) : a basic single "debian" VM (no network)
  * [demo/lan.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/lan.topo) : a LAN of 4 "debian" VMs interconnected by a switch 
  * [demo/chain.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/chain.topo) : a chain of 5 "debian" VMs interconnected by 4 switches
  * [demo/gw.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/gw.topo) : an example of LAN with a gateway connected to an external LAN
  * [demo/dmz.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/dmz.topo) : a more complex topology with two internal LANs (including a DMZ) 
  * [demo/vlan.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/vlan.topo) : a basic LAN divided in two VLANs
  * [demo/trunk.topo](https://gitlab.inria.fr/qemunet/core/raw/master/demo/trunk.topo) : two VLANs with trunking

### How to upgrade an image used by QemuNet? ###

For instance, if you want to install new packages in the "debian" image, you can do it easily like this:

```
$ ./qemunet.sh -l debian		# -l option implies -i
```

Then, in the VM, start network and install whatever you want:

```
$ dhclient eth0   # Internet access via Slirp interface of QEMU (no ping)
$ apt-get install package1 package2 ...
$ ...
$ rm /etc/resolv.conf
$ history -c
```

Be careful, all the modifications will be saved definitely in the raw image of the system, i.e. in the file *images/debian/debian.img*.

### Manual ###

QemuNet is based on a single bash script *qemunet.sh*. Here are detailed available options for this command:

```
Start/restore a session:
  qemunet.sh -t topology [-a images.tgz] [...]
  qemunet.sh -s session.tgz [...]
  qemunet.sh -S session/directory [...]
Options:
    -t <topology>: network topology file
    -s <session.tgz>: session archive
    -S <session directory>: session directory
    -h: print this help message
Advanced Options:
    -a <images.tgz>: load a qcow2 image archive for all VMs
    -c <config>: load system config file (default is qemunet.cfg)
    -x: launch VM in xterm terminal instead of SDL native window (only for linux system)
    -y: launch VDE switch management console in xterm terminal
    -i: enable Slirp interface for Internet access (ping not allowed)
    -m: mount shared directory in /mnt/host (default for linux system)
    -q: ignore and remove qcow2 images for the running session
    -M: disable mount
    -v: enable VLAN support
    -k: enable KVM full virtualization support (default)
    -K: disable KVM full virtualization support (not recommanded)
    -l <sysname>: launch a VM in standalone mode to update its raw disk image
```
  
### Configuration of QemuNet ###

Once you have download QemuNet, you need first to set the runtime commands for QEMU and VDE in *qemunet.sh*, if they don't use the default directory.

```
QEMU="/usr/bin/qemu-system-x86_64"
QEMUIMG="/usr/bin/qemu-img"    
VDESWITCH="/usr/bin/vde_switch"
```

Then, you have to provide a configuration file that defines several virtual systems and its parameters (name, type, disk image file, ...). The default configuration file is *[qemunet.cfg](https://gitlab.inria.fr/qemunet/core/raw/master/qemunet.cfg). It is a bash script that uses associative arrays (bash 4 or greater required). Here is a template file:

```
# IMGDIR="/absolute/path/to/raw/system/images"
IMGDIR=$(realpath images)

SYS[sysname]="linux|windows|..."
QEMUOPT[sysname]="qemu extra options"
FS[sysname]="/absolute/path/to/raw/system/sysname.img"
KERNEL[sysname]="/absolute/path/to/system/sysname.vmlinuz"  # optional, required for -x option
INITRD[sysname]="/absolute/path/to/system/sysname.initrd"   # optional, required for -x option
URL[sysname]="http://url/where/to/find/sysname.tgz"         # optional, url to download sysname.tgz (including FS, KERNEL and INITRD)
```

The SYS and FS arrays are required for each system. They respectively define the system type (linux, windows, ...) and the QEMU disk image file (in raw format). QEMUOPT can be used to pass additional options to QEMU when launching the VM, as for instance cpu type or max memory. See QEMU documentation for detailed options. Both KERNEL and INITRD are optional for linux system, but required if you want to launch the VMs in xterm (option -x).

### How to use my own image in QemuNet? ###

Instead of using the default GIT repository for *images*, you should prefer to install your own images in the *images* subdirectory (or elsewhere). In this case, you will need to update the configuration file provided in *qemunet.cfg*. Please visit this [wiki](http://aurelien.esnard.emi.u-bordeaux.fr/teaching/doku.php?id=qemunet:index) for further details.

### Documentation ###

  * QEMU: http://wiki.qemu.org
  * QEMU Networking: http://wiki.qemu.org/Documentation/Networking
  * VDE: http://vde.sourceforge.net/
  * VDE Manual : http://wiki.virtualsquare.org/wiki/index.php?title=VDE
  * Tutorial VDE : http://wiki.virtualsquare.org/wiki/index.php?title=VDE_Basic_Networking

### Other Solutions ###

  * NEmu : http://nemu.valab.net/ 
  * MarionNet : http://www.marionnet.org/EN/
  * User Mode Linux: http://user-mode-linux.sourceforge.net
  * GNS3: https://www.gns3.com

---
aurelien.esnard@u-bordeaux.fr