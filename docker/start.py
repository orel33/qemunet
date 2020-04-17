#!/usr/bin/env python3

import docker


client = docker.APIClient()
client.version()

hconfig = client.create_host_config(
    privileged=True,
    binds=[
        '/dev/kvm:/dev/kvm',
        '/dev/net/tun:/dev/net/tun',
    ])

container = client.create_container(
    image='orel33/qemunet',
    stdin_open=True,
    tty=True,
    command='/bin/bash',
    volumes=['/dev/kvm', '/dev/net/tun'],
    host_config=hconfig
)


client.start(container)

# $ docker ps
# $ docker attach <containerid>
