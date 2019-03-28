FROM orel33/mydebian:latest
MAINTAINER Aurelien Esnard <aurelien.esnard@u-bordeaux.fr>
WORKDIR /home/docker
ARG DEBIAN_FRONTEND=noninteractive

# qemu 
RUN apt-get install -y linux-image-amd64
RUN apt-get install -y socat rlwrap wget curl graphviz tcpdump unzip git
RUN apt-get install -y qemu qemu-kvm vde2 libattr1 libattr1-dev
RUN apt-get install -y libvirt0 virt-manager libvirt-clients libvirt-daemon-system
RUN apt-get install -y libguestfs-tools
# RUN apt-get install -y fuse fuseext2

# qemunet2
RUN git clone https://github.com/orel33/qemunet.git -b qemunet2
