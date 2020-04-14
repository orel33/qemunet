#!/usr/bin/env bash

#### QEMUNET Release 2.0 (2019-04) ####
#### QEMUNET Release 1.0 (2018-01) ####

# QemuNet: A light shell script based on QEMU Virtual Machine and
# VDE Virtual Switch to enable easy Virtual Networking.

# Copyright (C) 2016 - A. Esnard and A. Guermouche.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

### CHECK BASH 4 ###

if ! [ "$BASH_VERSINFO" -ge 4 ] ; then
    echo "ERROR: Bash version must be greater than or equal to 4.0!"
    exit 1
fi

### QEMUNET CONFIG ###

QEMUNET="$0"
# QEMUNETDIR="$(realpath $(dirname $QEMUNET))"
QEMUNETDIR="$(dirname $(readlink -f $QEMUNET))"
QEMUNETCFG="$QEMUNETDIR/qemunet.cfg"

### PARAMETERS ###

SESSIONID=$(mktemp -u -d qemunet-$USER-XXXXXX)
SESSIONDIR=""
# SESSIONLINK="session" # session link to session directory
SESSIONLINK="$HOME/qemunet-session" # session link to session directory
TOPOLOGY=""
EXTARCHIVE=""
SESSIONARCHIVE=""
THESYSNAME=""
OPTKERNELARGS=""

# mode
MODE=""  # "SESSION" or "STANDALONE" or "DOWNLOAD"

# default options
INTERNET=0
ACCEL=1
RAW=0
MOUNTDIR=1
MOUNTDISK=1
# COPYIN=0
XTERM=0
USEVLAN=0
# RMQCOW2=0
SWITCHTERM=0
DISPLAYMODE="graphic"   # xterm or rxvt or tmux or graphic or ...
BACKGROUND=0
REMOTEVIEWER=0          # remote viewer for VNC or SPICE server/display
VERBOSE=0
# RECOVER=0
TMUXID="qemunet"        # tmux session ID
QUIETBOOT=0             # quiet linux kernel boot (linux only)

# advanced options
SWMAXNUMPORTS=32    # max number of ports allowed in VDE_SWITCH (default 32)

### QEMUNET RUNTIME COMMAND ###

QEMU="qemu-system-x86_64"
QEMUIMG="qemu-img"
VDESWITCH="vde_switch"
SOCAT="socat"
WGET="wget"

TERMCMD () {
    local THISTERM="$1"
    local THISNAME="$2"
    if [ "$THISTERM" = "xterm" ] ; then
        echo "xterm -fg white -bg black -T $THISNAME -e" ;
        elif [ "$THISTERM" = "rxvt" ] ; then
        echo "rxvt -bg Black -fg White -title $THISNAME -e bash -c" ;
        elif [ "$THISTERM" = "gnome" ] ; then
        echo "gnome-terminal -- bash -c" ;
        elif [ "$THISTERM" = "xfce4" ] ; then
        echo "xfce4-terminal -T $THESYSNAME -x bash -c" ;
    else
        echo "ERROR: Invalid terminal display mode \"$THISTERM\"!"
    fi
}

### LOGO ###

LOGO() {
    cat $QEMUNETDIR/logo.txt
}

### USAGE ###

USAGE() {
    echo "A light shell script based on QEMU Virtual Machine (VM) and VDE Virtual Switch to enable easy Virtual Networking."
    echo
    echo "Start/restore a session:"
    echo "  $(basename $0) -t topology [-a extra.tgz] [...]"
    echo "  $(basename $0) -s session.tgz [...]"
    echo "  $(basename $0) -S session/directory [...]"
    echo "Options:"
    echo "    -t <topology>: network topology file"
    echo "    -s <session.tgz>: load session from an archive"
    echo "    -S <session directory>: load session from a directory"
    echo "    -h: print this help message"
    echo "Advanced Options:"
    echo "    -a <extra.tgz>: decompress an extra archive in session directory"
    echo "    -c <config>: load system config file (default is qemunet.cfg)"
    echo "    -x: launch VM in xterm terminal (only for linux system running on ttyS0)"
    echo "    -d <display mode>: launch VM with special display mode: "
    echo "       * graphic: standard QEMU display mode (default mode)"
    echo "       * xterm: QEMU serial/text mode running within xterm (same as -x option)"
    echo "       * rxvt: same as xterm mode, but using rxvt instead"
    echo "       * gnome: same as xterm mode, but using gnome-terminal instead"
    echo "       * xfce4: same as xterm mode, but using xfce4-terminal instead"
    echo "       * tmux: QEMU serial/text mode running within a tmux session (experimental)"
    echo "       * screen: QEMU serial/text mode running within a screen session (very experimental)"
    echo "       * vnc: use QEMU VNC display (experimental)"
    echo "       * spice: use QEMU SPICE display (experimental)"
    echo "       * none: no display"
    echo "       * nogaphic: no graphic (useful for a single host in text mode)"
    echo "More Advanced Options:"
    echo "    -l <sysname>: launch a VM in standalone mode to test it..."
    echo "    -L <sysname>: launch a VM in standalone mode using raw disk image (warning: image will be modified)"
    echo "    -D <sysname>: download system image from URL provided in config file"
    echo "    -b: run qemunet as a background command (experimental)"
    echo "    -m: try to mount an external directory <session directory>/<hostname> using 9p/virtio with 'host' tag (default, linux only)"
    echo "    -M: disable mount directory"
    echo "    -f: try to mount an extra disk <session directory>/<hostname>.disk (default)"
    echo "    -F: disable mount disk"
    echo "    -k: enable an accelerator: kvm, hvf (default)"
    echo "    -K: disable accelerator (not recommanded, too slow)"
    echo "    -v: enable VLAN support"
    echo "    -V: start remote viewer(s) for VNC or SPICE display mode"
    echo "    -y: launch VDE switch management console in terminal"
    echo "    -i: enable QEMU Slirp interface for Internet access (ping not allowed)"
    echo "    -q: quiet linux kernel boot (linux only)"
    echo "    -z <args>: append linux kernel arguments (linux only)"
    exit 0
}

### PARSE ARGUMENTS ###

GETARGS() {
    while getopts "t:a:s:S:c:l:L:D:imMfFkKxyvd:hbz:Vq" OPT; do
        case $OPT in
            t)
                if [ -n "$MODE" ] ; then USAGE ; fi
                MODE="SESSION"
                TOPOLOGY="$OPTARG"
            ;;
            s)
                if [ -n "$MODE" ] ; then USAGE ; fi
                MODE="SESSION"
                SESSIONARCHIVE="$OPTARG"
            ;;
            S)
                if [ -n "$MODE" ] ; then USAGE ; fi
                MODE="SESSION"
                SESSIONDIR="$OPTARG"
            ;;
            a)
                EXTARCHIVE="$OPTARG"
            ;;
            l)
                if [ -n "$MODE" ] ; then USAGE ; fi
                MODE="STANDALONE"
                SESSIONDIR="/tmp/$SESSIONID"
                mkdir -p $SESSIONDIR
                THESYSNAME="$OPTARG"
            ;;
            L)
                if [ -n "$MODE" ] ; then USAGE ; fi
                MODE="STANDALONE"
                RAW=1
                SESSIONDIR="/tmp/$SESSIONID"
                mkdir -p $SESSIONDIR
                THESYSNAME="$OPTARG"
            ;;
            D)
                if [ -n "$MODE" ] ; then USAGE ; fi
                MODE="DOWNLOAD"
                THESYSNAME="$OPTARG"
            ;;
            c)
                QEMUNETCFG="$OPTARG"
            ;;
            i)
                INTERNET=1
            ;;
            m)
                MOUNTDIR=1
            ;;
            M)
                MOUNTDIR=0
            ;;
            f)
                MOUNTDISK=1
            ;;
            F)
                MOUNTDISK=0
            ;;
            z)
                OPTKERNELARGS="$OPTARG"
            ;;
            q)
                QUIETBOOT=1
            ;;
            d)
                DISPLAYMODE="$OPTARG" # check $DISPLAY MODE
            ;;
            x)
                DISPLAYMODE="xterm"
            ;;
            y)
                SWITCHTERM=1
            ;;
            k)
                ACCEL=1
            ;;
            K)
                ACCEL=0
            ;;
            v)
                USEVLAN=1
            ;;
            V)
                REMOTEVIEWER=1
            ;;
            b)
                BACKGROUND=1
            ;;
            h)
                USAGE
            ;;
            \?)
                echo "Invalid option!"
                USAGE
            ;;
        esac
    done
    
    # check args
    if [ $# -eq 0 ] ; then USAGE ; fi
    if [ -z "$MODE" ] ; then USAGE ; fi
    
}

### 1) CHECK RC ###

CHECKRC() {
    
    echo "QEMUNET DIR: $QEMUNETDIR"
    echo "QEMU: $QEMU"
    echo "VDE SWITCH: $VDESWITCH"
    echo "SOCAT: $SOCAT"
    echo "WGET: $WGET"
    
    # check RC for QEMU & VDE
    if ! [ -x "$(type -P $QEMU)" ] ; then
        echo "ERROR: $QEMU not found!"
        exit 1
    elif ! [ -x "$(type -P $QEMUIMG)" ]
    then
        echo "ERROR: $QEMUIMG not found!"
        exit 1
    elif ! [ -x  "$(type -P $VDESWITCH)" ]
    then
        echo "ERROR: $VDESWITCH not found!"
        exit 1
    fi
    
    ### TODO: check qemu version
    # QEMUVERSION=$($QEMU --version |head -1 | cut -d ' ' -f4-)
    # QEMUMAJOR=$(echo $QEMUVERSION | cut -d '.' -f1)
    # QEMUMINOR=$(echo $QEMUVERSION | cut -d '.' -f2)
    # echo "QEMU VERSION: $QEMUMAJOR.$QEMUMINOR ($QEMUVERSION)"
    
    # if [ "$QEMUMAJOR" -lt "2" ] ; then
    #     echo "ERROR: QEMU version must be greater than or equal to 2.1!"
    #     exit 1
    # elif [ "$QEMUMAJOR" -eq "2" -a "$QEMUMINOR" -lt "1" ]
    # then
    #     echo "ERROR: QEMU version must be greater than or equal to 2.1!"
    #     exit 1
    # fi
    
    # check QEMU version >= 2.1
    echo "QEMU VERSION"
    $QEMU --version
    # TODO: check it is >= 2.1
    [ $? -ne 0 ] && echo "Error: fail to start $QEMU on this machine!" && exit 1
    
    # check wget
    if ! [ -x  "$(type -P $WGET)" ] ; then
        echo "ERROR: $WGET not found: download system images by yourself!"
        exit 1
    fi
    
    # check socat for VLAN support
    if [ "$USEVLAN" -eq 1 ] ; then
        if ! [ -x  "$(type -P $SOCAT)" ] ; then
            echo "ERROR: $SOCAT not found (only required for VLAN support)!"
            exit 1
        fi
    fi
    
    # check accelerator (test working only on Linux & MacOS system)
    if [ $ACCEL -eq 1 ] ; then
        # Other solution: lscpu | grep Virtualization
        if [[ "$OSTYPE" == "linux"* ]] ; then
            # TODO: QEMU: Checking if device /dev/kvm exists : PASS
            # TODO: QEMU: Checking if device /dev/kvm is accessible : PASS
            INTELCPUFLAGS=$(grep -c "vmx" /proc/cpuinfo)
            AMDCPUFLAGS=$(grep -c "svm" /proc/cpuinfo)
            INTELKVMMOD=$(lsmod | grep -c "kvm_intel")
            AMDKVMMOD=$(lsmod | grep -c "kvm_amd")
            if [ "$INTELCPUFLAGS" -ge 1 -a "$INTELKVMMOD" -ge 1 ] ; then
                echo "Accelerator: KVM enabled (intel)"
            elif [ "$AMDCPUFLAGS" -ge 1 -a "$AMDKVMMOD" -ge 1 ]
            then
                echo "Accelerator: KVM enabled (amd)"
            else
                echo "ERROR: Accelerator not available for QEMU!"
                exit 1
            fi
            elif [[ "$OSTYPE" == "darwin"* ]] ; then
            # TODO: what to check?
            echo "Accelerator: HVF enabled (maybe?)"
        else
            echo "Accelerator: not yet supported :-("
        fi
    else
        echo "ERROR: Accelerator not available for QEMU!"
    fi
    
    # using virt-manager
    if [ -x "$(type -P virt-host-validate)" ] ; then
        virt-host-validate qemu
        if [ $ACCEL -eq 1 ] ; then
            virt-host-validate qemu | grep "FAIL" &> /dev/null
            [ $? -eq 0 ] && echo "ERROR: fail to enable hardware accelerator!" && exit 1
        fi
    fi
    
    # check libvirt0 and libvirt-clients for -m option
    if [ $MOUNTDIR -eq 1 ] ; then
        which virsh &> /dev/null
        [ $? -ne 0 ] && echo "ERROR: virsh not found, but required for -m option!" && exit 1
    fi
    
    # check remote-viewer for VNC or SPICE display mode
    if [ $REMOTEVIEWER -eq 1 ] ; then
        if ! [ -x  "$(type -P remote-viewer)" ] ; then
            echo "ERROR: remote-viewer not found (only useful for VNC or SPICE display)!"
            exit 1
        fi
    fi
    
    # check libguestfs-tools for -C option
    # if [ $COPYIN -eq 1 ] ; then
    #     which virt-copy-in &> /dev/null
    #     [ $? -ne 0 ] && echo "ERROR: virt-copy-in not found, but required for -C option!" && exit 1
    # fi
    
}

### 2) INIT SESSION ###

INITSESSION() {
    
    echo "********** Starting QemuNet Session **********"
    
    ### init session directory
    if [ -z "$SESSIONDIR" ] ; then SESSIONDIR="/tmp/$SESSIONID" ; mkdir -p $SESSIONDIR ; fi
    if ! [ -d "$SESSIONDIR" ] ; then echo "ERROR: Session directory \"$SESSIONDIR\" does not exist!" ; exit 1 ; fi
    if ! [ -w "$SESSIONDIR" ] ; then echo "ERROR: Write access is not granted in \"$SESSIONDIR\"!" ; exit 1 ; fi
    
    # SESSIONLINKDIR=$(dirname $SESSIONDIR)
    # if ! [ -w "$SESSIONLINKDIR" ] ; then echo "ERROR: Write access is not granted in directory \"$SESSIONLINKDIR\" for session link!" ; exit ; fi
    # ln -T -sf $SESSIONDIR $SESSIONLINK  # -T means no target directory
    # if ! [ -d "$SESSIONLINK" ] ; then echo "ERROR: Session directory link \"$SESSIONLINK\" does not exist!" ; exit 1 ; fi
    # if ! [ -w "$SESSIONLINK" ] ; then echo "ERROR: Write access is not granted in \"$SESSIONLINK\"!" ; exit 1 ; fi
    ln -T -sf $SESSIONDIR $SESSIONLINK &> /dev/null || echo "WARNING: unable to create session link \"$SESSIONLINK\" in working directory!"
    
    if [ "$MODE" = "SESSION" ] ; then
        
        ### check session input param
        if [ -n "$TOPOLOGY" -a ! -r "$TOPOLOGY" ] ; then echo "ERROR: Topology file $TOPOLOGY not found!" ; exit 1 ; fi
        if [ -n "$EXTARCHIVE" -a ! -r "$EXTARCHIVE" ] ; then echo "ERROR: Extra archive $EXTARCHIVE not found!" ; exit 1 ; fi
        if [ -n "$SESSIONARCHIVE" -a ! -r "$SESSIONARCHIVE" ] ; then echo "ERROR: Session archive $SESSIONARCHIVE not found!" ; exit 1 ; fi
        
        ### prepare session files from input param
        if [ -r "$TOPOLOGY" ] ; then cp $TOPOLOGY $SESSIONDIR/topology ; fi
        if [ -r "$EXTARCHIVE" ] ; then tar xzf $EXTARCHIVE -C $SESSIONDIR ; fi
        if [ -r "$SESSIONARCHIVE" ] ; then tar xzf $SESSIONARCHIVE -C $SESSIONDIR ; fi
        
        # set environment
        TOPOLOGY="$SESSIONDIR/topology"
        
        # check
        if ! [ -r "$TOPOLOGY" ] ; then echo "ERROR: Topology file $TOPOLOGY missing!" ; exit 1 ; fi
        if ! [ -r "$QEMUNETCFG" ] ; then echo "ERROR: Config file $QEMUNETCFG missing!" ; exit 1 ; fi
        
    fi
    
    # lock session
    LOCK="$SESSIONDIR/lock"
    if [ -e "$LOCK" ] ; then
        echo "ERROR: Session Locked! Remove $LOCK file before restarting."
        exit 1
    else
        touch $LOCK
    fi
    
    ### PRINT SESSION
    echo "MODE: $MODE"
    echo "DISPLAY MODE: $DISPLAYMODE"
    echo "SESSION ID: $SESSIONID"
    echo "SESSION DIRECTORY: $SESSIONDIR"
    echo "SESSION LINK: $SESSIONLINK"
    echo "QEMUNET CFG: $QEMUNETCFG"
    echo "NETWORK TOPOLOGY: $TOPOLOGY"
    echo "SESSION ARCHIVE: $SESSIONARCHIVE"
    echo "EXTRA ARCHIVE: $EXTARCHIVE"
    
    ### START TMUX SERVER
    if [ "$DISPLAYMODE" = "tmux" ] ; then
        echo "=> Start tmux server (tmux session $TMUXID)"
        $QEMUNETDIR/misc/tmux-start.sh $SESSIONDIR
        [ $? -ne 0 ] && echo "ERROR: TMUX start failure!" && exit 1
    fi
    
    
}

### 3) LOAD CONF ###

declare -A SYS
declare -A FS
declare -A URL
declare -A QEMUOPT
declare -A KERNEL
declare -A INITRD
declare -A SWPORTNUM
declare -A SWPORTNUMTRUNK

LOADCONF() {
    
    # LOAD VM CONF
    if [ -r "$QEMUNETCFG" ] ; then
        source $QEMUNETCFG
    else
        echo "ERROR: File $QEMUNETCFG is missing!"
        exit 1
    fi
    
    echo "Loading VM Config File: $QEMUNETCFG"
    [ $VERBOSE -eq 0 ] && return
    
    # PRINT VM CONF
    for SYSNAME in "${!FS[@]}"; do
        echo "[$SYSNAME]"
        echo "* SYS = ${SYS[$SYSNAME]}"
        [ -n "${QEMUOPT[$SYSNAME]}" ] && echo "* QEMU OPT = ${QEMUOPT[$SYSNAME]}"
        
        HOSTFS="${FS[$SYSNAME]}"
        HOSTKERNEL="${KERNEL[$SYSNAME]}"
        HOSTINITRD="${INITRD[$SYSNAME]}"
        HOSTURL="${URL[$SYSNAME]}"
        
        OKFS="⚠"
        OKKERNEL="⚠"
        OKINITRD="⚠"
        if [ -r "$HOSTFS" ] ; then OKFS="✓" ; fi
        if [ -r "$HOSTKERNEL" ] ; then OKKERNEL="✓" ; fi
        if [ -r "$HOSTINITRD" ] ; then OKINITRD="✓" ; fi
        
        echo "* FS = $HOSTFS $OKFS"
        if [ ${KERNEL[$SYSNAME]+_} ]; then echo "* KERNEL = $HOSTKERNEL $OKKERNEL" ; fi
        if [ ${INITRD[$SYSNAME]+_} ]; then echo "* INITRD = $HOSTINITRD $OKINITRD" ; fi
        if [ ${URL[$SYSNAME]+_} ]; then echo "* URL = $HOSTURL" ; fi
        
        HOSTFSDIR=$(dirname  $HOSTFS)
        HOSTFSTGZ="$HOSTFSDIR/$SYSNAME.tgz"
        
        # CHECK CONF
        # if ! [ -r "$HOSTFS" ] ; then
        #    echo "WARNING: Disk image file for system $SYSNAME is missing! Check your path?"
        # fi
        
    done
    
}

### DOWNLOAD SYSTEM IMAGE ###

DOWNLOAD() {
    
    local SYSNAME=$1
    local FORCECHECK=0
    [ $# -eq 2 ] && local FORCECHECK=$2
    local HOSTFS="${FS[$SYSNAME]}"
    [ -z "$HOSTFS" ] && echo "ERROR: unknown system name \"$SYSNAME\"!" && exit 1
    local HOSTFSDIR=$(dirname  $HOSTFS)
    local HOSTFSTGZ="$HOSTFSDIR/$SYSNAME.tgz"
    local HOSTURL=${URL[$SYSNAME]}
    local HOSTMD5SUM="$HOSTFSDIR/$SYSNAME.md5sum"
    local HOSTMD5SUMURL=""
    
    # check if host file already exists
    if [ -r "$HOSTFS" ] ; then
        echo "=> Image for \"$SYSNAME\" already exists..."
        [ $FORCECHECK -eq 0 ] && return
    fi
    
    # Download system image
    if [ ! -r "$HOSTFSTGZ" -a -n "$HOSTURL" ] ; then
        echo -n "=> Downloading \"$SYSNAME\" image from $HOSTURL... "
        $WGET -q --show-progress -P $QEMUNETDIR/images $HOSTURL
        RET=$?
        if [ $RET -eq 0 ] ; then
            echo "success!" ; rm -f $HOSTFS
        else
            echo "failure!"
        fi
    fi
    
    # if [ ${URL[$SYSNAME]+_} ] ; then
    #     echo "=> Downloading \"$SYSNAME\" image from $HOSTURL"
    #     $WGET --continue --show-progress -q -nc $HOSTURL -O $HOSTFSTGZ
    # else
    #     echo "ERROR: raw image file \"$HOSTFS\" not found for \"$SYSNAME\" system and no URL provided to download it!"
    #     exit 1
    # fi
    
    # Download checksum file
    if [ -n "$HOSTURL" ] ; then
        local HOSTMD5SUMURL="$(dirname $HOSTURL)/$SYSNAME.md5sum"
        [ -f "$HOSTMD5SUM" ] && rm -f $HOSTMD5SUM
        echo -n "=> Downloading checksum file for \"$SYSNAME\"... "
        $WGET -q -P $QEMUNETDIR/images $HOSTMD5SUMURL &> /dev/null
        if [ $? -eq 0 ] ; then echo "success!" ; else echo "failure!" ; fi
    fi
    
    # Check host image
    if [ -r "$HOSTFSTGZ" -a -r "$HOSTMD5SUM" ] ; then
        echo -n "=> Compare MD5 checksum for \"$SYSNAME\"... "
        ( cd $QEMUNETDIR/images && md5sum --status -c $SYSNAME.md5sum ) &> /dev/null
        if [ $? -eq 0 ] ; then echo "success!" ; else echo "failure!" ; fi
    fi
    
    # Uncompress disk image
    if [ -r "$HOSTFSTGZ" -a ! -r "$HOSTFS" ] ; then
        echo -n "=> Extracting host image for $SYSNAME... "
        tar xzf $HOSTFSTGZ -C $HOSTFSDIR &> /dev/null
        if [ $? -eq 0 ] ; then echo "success!" ; else echo "failure!" ; fi
    fi
    
    return 0
}


### QCOW FILE SYSTEM ###

CREATEQCOW() {
    HOSTFS=$1
    HOSTQCOW=$2
    IMGCMD=""
    # if [ "$RMQCOW2" -eq 1 ] ; then rm -f "$HOSTQCOW" ; fi
    if ! [ -r "$HOSTQCOW" ] ; then IMGCMD="$QEMUIMG create -q -b $HOSTFS -f qcow2 $HOSTQCOW" ;
else IMGCMD="$QEMUIMG rebase -q -u -b $HOSTFS $HOSTQCOW" ; fi
    echo "[$(basename $HOSTQCOW)] $IMGCMD"
    $IMGCMD
}

### SWITCH & HUB ###

# SWITCHDIRS=""
# SWITCHPIDS=""
# TRUNKPIDS=""

SWITCH() {
    SWITCHNAME=$1
    SWITCHDIR="$SESSIONDIR/switch/$SWITCHNAME"
    # REALSESSION=$(realpath $SESSIONDIR) # !!!
    SWITCHMGMT="$SESSIONDIR/$SWITCHNAME.mgmt"
    # SWITCHDIRS="$SWITCHDIR $SWITCHDIRS"
    PIDFILE="$SESSIONDIR/$SWITCHNAME.pid"
    if ! [ -d "$SWITCHDIR" ] ; then rm -rf $SWITCHDIR ; fi
    mkdir -p $SWITCHDIR
    
    if [ "$DISPLAYMODE" = "tmux" ] ; then
        CMD="$VDESWITCH -s $SWITCHDIR -p $PIDFILE -M $SWITCHMGMT"       # disable daemon mode
        echo "[$SWITCHNAME] $CMD"
        tmux new-window -t $TMUXID -n $SWITCHNAME bash -c "${CMD[@]}" # detached
    else
        CMD="$VDESWITCH -d -s $SWITCHDIR -p $PIDFILE -M $SWITCHMGMT"    # daemon mode
        echo "[$SWITCHNAME] $CMD"
        $CMD
    fi
    
    # PID=$(cat $PIDFILE)
    # SWITCHPIDS="$PID $SWITCHPIDS"
    SWPORTNUM[$SWITCHNAME]=1
    if [ "$USEVLAN" -eq 1 ]; then
        # by default, only 32 ports are available! Using port numbers
        # greater than 20 for trunking.
        SWPORTNUMTRUNK[$SWITCHNAME]=20
    fi
    # launch VDE switch management console in xterm terminal
    if [ "$SWITCHTERM" -eq 1 ] ; then
        CMD=$(TERMCMD xterm $SWITCHNAME)
        CMD="${CMD} vdeterm $SWITCHMGMT"
        echo "[$SWITCHNAME] $CMD"
        $CMD &
    fi
    
    # save qemu command
    CMDFILE="$SESSIONDIR/$SWITCHNAME.sh"
    echo $CMD > $CMDFILE
    
}

HUB() {
    SWITCHNAME=$1
    SWITCHDIR="$SESSIONDIR/switch/$SWITCHNAME"
    # SWITCHDIRS="$SWITCHDIR $SWITCHDIRS"
    PIDFILE="$SESSIONDIR/$SWITCHNAME.pid"
    if ! [ -d "$SWITCHDIR" ] ; then rm -rf $SWITCHDIR ; fi
    mkdir -p $SWITCHDIR
    CMD="$VDESWITCH -d -s $SWITCHDIR -p $PIDFILE -hub"
    echo "[$SWITCHNAME] $CMD"
    $CMD
    # PID=$(cat $PIDFILE)
    # SWITCHPIDS="$PID $SWITCHPIDS"
    
    # TODO: merge ths routine with SWITCH()
    # BUG: tmux support not available?
    
    # save qemu command
    CMDFILE="$SESSIONDIR/$SWITCHNAME.sh"
    echo $CMD > $CMDFILE
}

### VIRTUAL NETWORK ###

HOSTNUM=0

# NETWORK netdev switch0[:vlan0] switch1[:vlan1] ...

NETWORK() {
    NETDEV=$1
    shift 1
    SWITCHNAMES=$*
    NETOPT=""
    IFACENUM=0
    for SWITCHNAME in $SWITCHNAMES ; do
        # test if VLAN is used?
        # VLAN=$(echo $SWITCHNAME | awk -F ":" '{print $2}')  # get VLAN tag
        # if [ "$USEVLAN" -eq 0 -a -n "$VLAN" ] ; then echo "ERROR: VLAN used in topology, but VLAN support not enabled (option -v)!" ; exit 1 ; fi
        # if [ "$USEVLAN" -eq 1 -a -n "$VLAN" ] ; then SWITCHNAME=$(echo $SWITCHNAME | awk -F ":" '{print $1}') ; else VLAN=0 ; fi
        # REALSESSION=$(realpath $SESSIONDIR) # !!!
        SWITCHMGMT="$SESSIONDIR/switch/$SWITCHNAME.mgmt"
        SWITCHDIR="$SESSIONDIR/switch/$SWITCHNAME"
        SWITCHLOG="$SESSIONDIR/switch/$SWITCHNAME.log"
        SWITCHCMD="$SESSIONDIR/switch/$SWITCHNAME.cmd"
        ID="$SWITCHNAME"
        # MAC=$(hexdump -n3 -e'/3 "AA:AA:AA" 3/1 ":%02X"' /dev/urandom)
        MAC=$(printf "AA:AA:AA:AA:%02x:%02x" $HOSTNUM $IFACENUM)
        # echo "MAC= $MAC"
        PORTNUM=${SWPORTNUM[$SWITCHNAME]}
        NETOPT="$NETOPT -netdev vde,sock=$SWITCHDIR,port=$PORTNUM,id=$ID -device $NETDEV,netdev=$ID,mac=$MAC"
        # echo "=> plug $HOSTNAME:eth$IFACENUM to switch $SWITCHNAME:$PORTNUM (vlan $VLAN)"
        echo "=> plug $HOSTNAME:eth$IFACENUM to switch $SWITCHNAME:$PORTNUM"
        # VLAN management (http://wiki.virtualsquare.org/wiki/index.php/VDE)
        if [ "$USEVLAN" -eq 1 ] ; then
            echo "port/setnumports $SWMAXNUMPORTS" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &> /dev/null   # set max num ports (TODO: only the first time)
            echo "port/create $PORTNUM" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &> /dev/null              # create switch port
            # echo "vlan/create $VLAN" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &> /dev/null               # create new VLAN (TODO: create only the first time)
            # echo "port/setvlan $PORTNUM $VLAN" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &> /dev/null     # set port to vlan (as untagged)
            ## echo "vlan/addport $VLAN $PORTNUM" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &> /dev/null    # set port to vlan (as tagged)
            if [ -r $SWITCHCMD ] ; then
                echo "load $SWITCHCMD" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &> /dev/null               # load switch configuration
                echo "=> load switch configuration \"$SWITCHCMD\""
            fi
        fi
        # print switch log for debug
        echo "vlan/allprint" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &>> $SWITCHLOG                     # print log
        echo "port/allprint" | $SOCAT - "UNIX-CONNECT:$SWITCHMGMT" &>> $SWITCHLOG                     # print log
        
        IFACENUM=$(expr $IFACENUM + 1)
        SWPORTNUM[$SWITCHNAME]=$(expr $PORTNUM + 1)
    done
    CMD="$CMD $NETOPT"
}

### VIRTUAL HOST ###

# HOST sysname hostname[/displaymode] switch0[:vlan0] switch1[:vlan1] ...
HOST() {
    
    # SYSNAME=$1
    local SYSNAME=$(echo "$1" | cut -d/ -f1)            # by default, cut print all line if no delimiters
    local THISDISPLAYMODE=$(echo "$1" | cut -d/ -f2 -s) # -s option: supress line with no delimiters
    local HOSTNAME=$2
    shift 2
    local SWITCHNAMES=$*
    
    local HOSTFS="${FS[$SYSNAME]}"
    [ -z "$HOSTFS" ] && echo "ERROR: Invalid config provided for \"$SYSNAME\"!" && exit 1
    local HOSTOPT="${QEMUOPT[$SYSNAME]}"
    local HOSTSYS="${SYS[$SYSNAME]}"
    local HOSTKERNEL="${KERNEL[$SYSNAME]}"
    local HOSTINITRD="${INITRD[$SYSNAME]}"
    local HOSTQCOW="$SESSIONDIR/$HOSTNAME.qcow2"
    [ -z "$THISDISPLAYMODE" ] && local THISDISPLAYMODE="$DISPLAYMODE" # fallback to default
    
    # check SESSIONDIR
    if ! [ -d "$SESSIONDIR" ] ; then echo "ERROR: Session directory $SESSIONDIR does not exist!" ; exit 1 ; fi
    
    # basic options
    CMD="$QEMU -name $HOSTNAME -rtc base=localtime"
    
    # accelerator option (by default)
    # if [ $ACCEL -eq 1 ] ; then CMD="$CMD -enable-kvm" ; fi
    if [ $ACCEL -eq 1 ] ; then CMD="$CMD -M accel=kvm:hvf:hax" ; fi # TODO: add option "-cpu host" here or in qemunet.cfg
    
    # specific QEMU options
    CMD="$CMD $HOSTOPT" #  -fda /dev/fd0
    
    # check system image file
    if ! [ -r "$HOSTFS" ] ; then DOWNLOAD $SYSNAME ; fi
    if ! [ -r "$HOSTFS" ] ; then echo "ERROR: Raw image file \"$HOSTFS\" not found for \"$SYSNAME\" system!"; exit 1 ; fi
    
    # use raw or qcow2 system image
    if [ "$RAW" -eq 1 ] ; then
        # CMD="$CMD -hda $HOSTFS"   # use raw image file
        CMD="$CMD -drive file=$HOSTFS,format=raw,index=0,media=disk"
    else
        # ln -sf $HOSTFS $SESSIONDIR/$HOSTNAME.img
        # create qcow2 if needed
        CREATEQCOW $HOSTFS $HOSTQCOW
        if ! [ -r "$HOSTQCOW" ] ; then echo "ERROR: qcow2 image file $HOSTQCOW not found!"; exit 1 ; fi
        # CMD="$CMD -hda $HOSTQCOW" # using qcow2 image file (raw not modified)
        CMD="$CMD -drive file=$HOSTQCOW,format=qcow2,index=0,media=disk"
        # add extra disk in VM (/dev/sdb)
        if [ $MOUNTDISK -eq 1 ] ; then
            HOSTMOUNTDISK="$SESSIONDIR/$HOSTNAME.disk"
            # [ -f "$HOSTMOUNTDISK" ] && CMD="$CMD -hdb $HOSTMOUNTDISK"
            [ -f "$HOSTMOUNTDISK" ] && CMD="$CMD -drive file=$HOSTMOUNTDISK,format=raw,index=1,media=disk"
            # [ -f "$HOSTMOUNTDISK" ] && CMD="$CMD -usb -usbdevice disk:raw:$HOSTMOUNTDISK" # deprecated
            # [ -f "$HOSTMOUNTDISK" ] && CMD="$CMD -device piix3-usb-uhci -drive id=usbdisk,file=$HOSTMOUNTDISK,format=raw,if=none -device usb-storage,drive=usbdisk"
            # [ -f "$HOSTMOUNTDISK" ] && CMD="$CMD -device nec-usb-xhci,id=xhci -drive id=usbdisk,file=$HOSTMOUNTDISK,format=raw,if=none -device usb-storage,bus=xhci.0,drive=usbdisk"
        fi
        # # copy files inside VM
        # if [ $COPYIN -eq 1 ] ; then
        #     # vmware|qemu bug (https://bugzilla.redhat.com/show_bug.cgi?id=1648403)
        #     # force_tcg: http://libguestfs.org/guestfs.3.html#force_tcg => disable KVM in virt-copy-in
        #     # export LIBGUESTFS_BACKEND_SETTINGS=force_tcg
        #     [ -d "$SESSIONDIR/$HOSTNAME" ] && virt-copy-in -a $HOSTQCOW $SESSIONDIR/$HOSTNAME/* /mnt/host/
        # fi
    fi
    
    # share directory /mnt/host (linux only)
    if [ "$HOSTSYS" = "linux" -a "$MOUNTDIR" -eq 1 ] ; then
        SHAREDIR="$SESSIONDIR/$HOSTNAME"
        mkdir -p $SHAREDIR
        # SECURITY="mapped" # files are created with Qemu user credentials and the client-user's credentials are saved in extended attributes.
        # SECURITY="none"   # files are directly created with client-user's credentials.
        SECURITY="mapped"   # bug: problem if session directory is on NFS, use /tmp.
        CMD="$CMD -fsdev local,id=share0,path=$SHAREDIR,security_model=$SECURITY -device virtio-9p-pci,fsdev=share0,mount_tag=host"
    fi
    
    # select network device
    NETDEV="e1000"
    if [ "$HOSTSYS" = "windows" ] ; then NETDEV="rtl8139" ; fi # required for winxp only
    
    # vde network
    NETWORK $NETDEV $SWITCHNAMES
    
    # slirp network
    if [ "$INTERNET" -eq 1 ] ; then CMD="$CMD -netdev user,id=mynet0 -device $NETDEV,netdev=mynet0" ; fi
    
    # load external linux kernel (if available)
    if [ "$HOSTSYS" = "linux" -a -r "$HOSTKERNEL" -a -r "$HOSTINITRD" ] ; then
        # append kernel args
        # both tty0 and ttyS0 are useful
        KERNELARGS="root=/dev/sda1 rw net.ifnames=0 console=ttyS0 console=tty0"
        # ifnames=0 disables the new "consistent" device naming scheme, using instead the classic ethX interface naming scheme.
        # CMD="$CMD -kernel $HOSTKERNEL -initrd $HOSTINITRD -append \"$KERNELARGS\""
        local USER=$(id -un)
        KERNELARGS="$KERNELARGS user=$USER"
        [ $QUIETBOOT -eq 1 ] && KERNELARGS="$KERNELARGS quiet" # systemd.show_status=false rd.systemd.show_status=false
        CMD="$CMD -kernel $HOSTKERNEL -initrd $HOSTINITRD -append '$KERNELARGS $OPTKERNELARGS'"
    fi
    
    # store qemu pid in file
    
    CMD="$CMD -pidfile $SESSIONDIR/$HOSTNAME.pid"
    
    ### launch qemu command with different display mode (socket, xterm, graphic)
    
    if [ "$THISDISPLAYMODE" = "none" ] ; then # no display
        # CMD="$CMD -nographic"
        CMD="$CMD -display none"
        echo "[$HOSTNAME] $CMD"
        bash -c "${CMD[@]}" &
        # nographic
        elif [ "$THISDISPLAYMODE" = "nographic" ] ; then # text mode
        CMD="$CMD -nographic"
        echo "[$HOSTNAME] $CMD"
        bash -c "${CMD[@]}" &
        # screen
        elif [ "$THISDISPLAYMODE" = "screen" ] ; then # no display
        CMD="$CMD -nographic"
        echo "[$HOSTNAME] $CMD"
        screen -S "qemunet:$HOSTNAME" -d -m bash -c "${CMD[@]}" # detached
        # tmux
        elif [ "$THISDISPLAYMODE" = "tmux" ] ; then
        CMD="$CMD -nographic"
        echo "[$HOSTNAME] $CMD"
        tmux new-window -t $TMUXID -n $HOSTNAME bash -c "${CMD[@]}" # detached
        # xterm
        elif [ "$THISDISPLAYMODE" = "xterm" -o "$THISDISPLAYMODE" = "rxvt" -o "$THISDISPLAYMODE" = "xfce4" -o "$THISDISPLAYMODE" = "gnome" ] ; then
        CMD="$CMD -nographic"
        XCMD=$(TERMCMD $THISDISPLAYMODE $HOSTNAME)
        echo "[$HOSTNAME] $XCMD $CMD"
        $XCMD "${CMD[@]}" &
        # vnc
        elif [ "$THISDISPLAYMODE" = "vnc" ] ; then
        VNCPORT=5900            # default port for VNC
        ((VNCPORT+=HOSTNUM))
        CMD="$CMD -vnc :$HOSTNUM -usb -device usb-tablet"
        echo "[$HOSTNAME] $CMD"
        bash -c "${CMD[@]}" &
        RVCMD="remote-viewer vnc://localhost:$VNCPORT"
        [ $REMOTEVIEWER -eq 1 ] && echo "[$HOSTNAME] $RVCMD" && $RVCMD &
        # spice
        elif [ "$THISDISPLAYMODE" = "spice" ] ; then
        SPICEPORT=5900
        ((SPICEPORT+=HOSTNUM))
        CMD="$CMD -vga qxl -spice port=$SPICEPORT,addr=127.0.0.1,disable-ticketing"
        # SPICEOPT are useful for copy & paste based on vdagent installed in guest...
        SPICEOPT="-device virtio-serial -chardev spicevmc,id=vdagent,name=vdagent -device virtserialport,chardev=vdagent,name=com.redhat.spice.0"
        CMD="$CMD $SPICEOPT"
        echo "[$HOSTNAME] $CMD"
        bash -c "${CMD[@]}" &
        RVCMD="remote-viewer spice://localhost:$SPICEPORT"
        [ $REMOTEVIEWER -eq 1 ] && echo "[$HOSTNAME] $RVCMD" && $RVCMD &
        # standard / graphic mode
    else
        echo "[$HOSTNAME] $CMD"
        bash -c "${CMD[@]}" &
    fi
    
    
    PID=$!
    
    # save qemu command
    CMDFILE="$SESSIONDIR/$HOSTNAME.sh"
    echo $CMD > $CMDFILE
    
    # echo "[$HOSTNAME] pid $PID"
    # next
    # HOSTPIDS="$HOSTPIDS $PID"
    # HOSTNUM=$(expr $HOSTNUM + 1)
    ((HOSTNUM++))
}

### SWITCH TRUNKING ###

TRUNK(){
    
    if [ "$USEVLAN" -eq 0 ]; then echo "ERROR: VLAN used in topology, but VLAN support not enabled (option -v)!" ; exit 1 ; fi
    if [ $# -ne 2 ]; then echo "ERROR: Trunk link can be used only between 2 switches"; exit 1 ; fi;
    
    SWITCH1=$1
    SWITCH2=$2
    
    if ! [ -f  $SESSIONDIR/$SWITCH1.pid ]; then "ERROR: Unknown switch $SWITCH1 !" ; exit 1 ; fi
    if ! [ -f  $SESSIONDIR/$SWITCH2.pid ]; then "ERROR: Unknown switch $SWITCH2 !" ; exit 1 ; fi
    
    echo "=> Trunk link between switch $SWITCH1 and switch $SWITCH2"
    
    SWPORTNUMTRUNK[$SWITCH1]=$(expr ${SWPORTNUMTRUNK[$SWITCH1]} + 1)
    SWPORTNUMTRUNK[$SWITCH2]=$(expr ${SWPORTNUMTRUNK[$SWITCH2]} + 1)
    
    # a strange behavior was observed with the following command, thus we need to move to a writable directory before calling dpipe ...
    echo "[$SWITCH1]---[$SWITCH2] dpipe vde_plug -p ${SWPORTNUMTRUNK[$SWITCH1]} $SWITCH1  = vde_plug  -p ${SWPORTNUMTRUNK[$SWITCH2]} $SWITCH2"
    (cd $SESSIONDIR; dpipe vde_plug -p ${SWPORTNUMTRUNK[$SWITCH1]} $SESSIONDIR/switch/$SWITCH1  = vde_plug  -p ${SWPORTNUMTRUNK[$SWITCH2]} $SESSIONDIR/switch/$SWITCH2  >& /dev/null &)
    
    PID=$!  # FIXME: use pid of dpipe command instead of subshell?
    # TRUNKPIDS="$TRUNKPIDS $PID"
    echo $PID > $SESSIONDIR/trunk_$SWITCH1_$SWITCH2.pid
}

### BG ###

BG() {
    # background current script!
    # https://unix.stackexchange.com/questions/403895/automatically-move-a-script-into-the-background
    # FIXME: sometimes... BG fail?!
    echo "ME=$$"
    ( sleep 1 ; kill -STOP $$ ; ps -S -O size,pmem --forest ; kill -CONT $$ )  &
}

### WAIT ###

WAIT() {
    echo "* ********* Waiting end of Session **********"
    # echo "ME: $$"
    # echo "wait pids: $HOSTPIDS"
    # ALLPIDS=$(jobs -rp)  # get all jobs launched by this script
    # echo "HOST PIDS: $HOSTPIDS"  # empty for tmux or screen display mode!
    # echo "ALL PIDS: $ALLPIDS"
    # echo "SWITCH PIDS: $SWITCHPIDS"
    
    # wait $HOSTPIDS  # only wait hosts (not switch, etc)
    # screen -ls
    # echo "=> To halt properly each virtual machine, type \"poweroff\", else press ctrl-c here!"
    echo "sleep... press ctrl-c to end me!"
    # [ $BACKGROUND -eq 1 ] && BG
    # if [ $BACKGROUND -eq 1 ] ; then
    #     kill -STOP $$
    #     kill -CONT $$
    #     # echo "not yet stopped!"
    #     fi
    
    while true; do sleep 1000; done
}

### EXIT ###

EXIT() {
    echo "=> trap exit!"
    source $QEMUNETDIR/misc/qemunet-exit.sh $SESSIONDIR
    if [ "$DISPLAYMODE" = "tmux" ] ; then $QEMUNETDIR/misc/tmux-exit.sh ; fi
    if [ "$DISPLAYMODE" = "screen" ] ; then $QEMUNETDIR/misc/screen-exit.sh ; fi
}

### START ###

START() {
    echo "********** Let's Rock **********"
    CHECKRC
    echo "********** Loading VM Config **********"
    LOADCONF
    
    # trap exit of foreground session
    [ $BACKGROUND -eq 0 ] && trap 'EXIT' EXIT # call exit if not background
    
    # echo "********** Init Session **********"
    if [ "$MODE" = "SESSION" ] ; then
        INITSESSION
        source $TOPOLOGY
        elif [ "$MODE" = "STANDALONE" ] ; then
        INITSESSION
        HOST "$THESYSNAME" "$THESYSNAME"
        elif [ "$MODE" = "DOWNLOAD" ] ; then
        DOWNLOAD "$THESYSNAME" 1    # FORCE MD5 CHECKSUM
        exit 0
    else
        echo "ERROR: Invalid QemuNet mode \"$MODE\"!"
    fi
    echo "=> Your QemuNet session is running in this directory: $SESSIONDIR -> $SESSIONLINK"
    
    # echo "=> You can save your session directory as follow: \"cd $SESSIONDIR ; tar cvzSf mysession.tgz * ; cd -\""
    # echo "=> Then, to restore it, type: \"$QEMUNETDIR/qemunet.sh -s mysession.tgz\""
    
    # explain how to attach tmux & screen
    if [ "$DISPLAYMODE" = "tmux" ] ; then echo "=> Just launch command \"tmux a\" to attach TMUX session..." ; fi
    
    [ $BACKGROUND -eq 0 ] && WAIT
    # trap call EXIT at regular exit!
}

### LET's ROCK ###

LOGO
GETARGS $*
START

# EOF
