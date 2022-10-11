# Containerization

> Containerization is a form of virtualization where applications run in isolated user spaces, called containers, 
> while using the same shared operating system (OS). One of the benefits of containerization is that a container 
> is essentially a fully packaged and portable computing environment.

## Definitions

Cloud Native
1. Microservices oriented
1. Packaged as containers
1. Dynamically orchestrated
- CNCF.io | Cloud Native Computing Foundation (K8S, Prometheus, Fluentd...)

## Containers
- [Docker](./docker)
  - [Voting App](./docker/voting-app.md) sample

## Orchestrators
- [Docker Swarm](./docker/swarm.md)
- [Kubernetes](./kubernetes)
  - Tools:
    - [kubectl](kubernetes/tools/kubectl.md)
    - [Minikube](kubernetes/tools/minikube.md)

## Virtual Machines
- [Vagrant](./vagrant)

## Provisioning
- [Multipass](./multipass)
  - `$ multipass launch -n master`
  - `$ multipass shell master`
  - `$ multipass exec master ...`
  - `$ multipass launch -n worker1`

## Hypervisors
- [VirtualBox](./virtualbox)
- VMware Fusion: https://www.vmware.com/products/fusion
- HyperKit: https://github.com/moby/hyperkit)
- Parrales
