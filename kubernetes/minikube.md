# Minikube

- All the Kubernetes components on a **SINGLE LOCAL** virtual machine or in Docker: DO NOT USE IN PRODUCTION.
- Need a hypervisor as HyperKit or VirtualBox
- https://github.com/kubernetes/minikube  `#INSTALL`
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Installation/minikube.md

## Install
```shell
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
$ chmod +x minikube
$ sudo mv minikube /usr/local/bin/
```

## Start
```shell
$ minikube start
$ kubectl get node
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   13s   v1.25.0
$ minikube start --driver docker --nodes 3
$ kubectl get no,deploy,pod,svc --all-namespaces
```

## Monitoring
```shell
$ minikube status
$ minikube ip                                        ## To get the IP of the VM
$ kubectl get no,deploy,pod,svc --all-namespaces     ## To get all installed Kubernetes objects
```

## Cleanup
```shell
$ minikube delete
```
