# Multipass

> Provisioning tool: Ubuntu VMs on demand for any workstation

- https://multipass.run/ `#INSTALL`
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Installation/multipass.md
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Installation/kubeadm.md

## Architecture
```
     ┌───────────────────────────────────────────────┐
     │ (Mac) OS                                      │
     │ ┌────────────────────────────────────┐        │
     │ │     Multipass                      │        │
     │ │ ┌─────────────────────────┐        │        │
     │ │ │   Ubuntu                │        │        │
     │ │ │ ┌──────────────┐        │        │        │
     │ │ │ │ (Docker)     │        │        │        │
     │ │ │ └──────────────┘        │        │        │
     │ │ └─────────────────────────┘        │        │
     │ └────────────────────────────────────┘        │
     └───────────────────────────────────────────────┘
```

## Commands
```shell
$ multipass launch -n node1
$ multipass info node1
$ multipass info node1 --format json
$ multipass list
$ multipass shell node1

$ multipass exec node1 -- /bin/bash -c "curl -sSL https://get.docker.com | sh"
$ multipass exec node1 -- sudo docker version

$ mkdir /tmp/test && touch /tmp/test/hello
$ multipass mount /tmp/test node1:/usr/share/test
$ multipass exec node1 -- ls /usr/share/test
$ multipass umount node1:/usr/share/test

$ multipass exec node1 -- ls /tmp/hello
$ multipass transfer /tmp/test/hello node1:/tmp/hello
$ multipass exec node1 -- ls /tmp/hello

$ multipass delete -p node1 node2     # -p To Purge (really remove)
```
