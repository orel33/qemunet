#!/bin/bash
docker run -it --device /dev/kvm orel33/qemunet:latest
# docker run -it --privileged orel33/miniqemu