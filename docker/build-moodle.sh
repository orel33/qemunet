#!/bin/bash

docker build -t "orel33/qemu:latest" -f Dockerfile.qemu . && docker --config="/root/.docker.orel/" push "orel33/qemu:latest"
docker build -t "orel33/qemunet:latest" -f Dockerfile.qemunet . && docker --config="/root/.docker.orel/" push "orel33/qemunet:latest"
