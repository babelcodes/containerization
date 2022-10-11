# Kubernetes - kubectl

> Binary used to communicate with the server API (via HTTP requests)

- Part of [Kubernetes](../README.md)
- Used for:
  - Manage clusters
  - Manage resources
  - Troubleshooting
- Imperative (commandline, fast but no tracking) vs Declarative (configuration files, under VCS)

## Installation

- https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Installation/kubectl.md `#INSTALL`
```shell
$ VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/kubectl
$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin/kubectl
```
- Can use [Minikube](minikube.md) to use `kubectl`

### Autocompletion
- For commands and their options, but also for available resources (pod names...)
```shell
$ sudo apt-get install bash-completion
$ source <(kubectl completion bash)
```

## Available resources
```shell
$ kubectl api-resources
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
componentstatuses                 cs           v1                                     false        ComponentStatus
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
limitranges                       limits       v1                                     true         LimitRange
namespaces                        ns           v1                                     false        Namespace
nodes                             no           v1                                     false        Node
persistentvolumeclaims            pvc          v1                                     true         PersistentVolumeClaim
persistentvolumes                 pv           v1                                     false        PersistentVolume
pods                              po           v1                                     true         Pod
...
storageclasses                    sc           storage.k8s.io/v1                      false        StorageClass
volumeattachments                              storage.k8s.io/v1                      false        VolumeAttachment
```

## Resources documentation
```shell
$ kubectl explain pod
KIND:     Pod
VERSION:  v1
DESCRIPTION:
     Pod is a collection of containers that can run on a host. This resource is
     created by clients and scheduled onto hosts.
FIELDS:
   apiVersion	<string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
   kind	<string>
     Kind is a string value representing the REST resource this object
...

$ kubectl explain pod.spec.containers.command
KIND:     Pod
VERSION:  v1
FIELD:    command <[]string>
DESCRIPTION:
     Entrypoint array. Not executed within a shell. The container image's
     ENTRYPOINT is used if this is not provided. Variable references $(VAR_NAME)
     are expanded using the container's environment. If a variable cannot be
     resolved, the reference in the input string will be unchanged. Double $$
     are reduced to a single $, which allows for escaping the $(VAR_NAME)
     syntax: i.e. "$$(VAR_NAME)" will produce the string literal "$(VAR_NAME)".
     Escaped references will never be expanded, regardless of whether the
     variable exists or not. Cannot be updated. More info:
     https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell
```

## Resources state
```shell
$ kubectl get no,deploy,pod,svc --all-namespaces
$ kubectl get pods -n kube-system

$ kubectl get all -n kubernetes-dashboard

$ kubectl get pod                ##
$ kubectl get pod/www -o yaml    ##
$ kubectl describe pod/www       ## => Spec of the pod (events...)
```

### JSONPath
- to get nested property
- https://kubernetes.io/docs/reference/kubectl/jsonpath/
- Alternative to https://stedolan.github.io/jq/
  - jq is a lightweight and flexible command-line JSON processor
```shell
$ kubectl get po/www -o jsonpath='{.spec.containers[0].image}'
$ kubectl get pods -n kube-system \
  -o jsonpath='{range.items[*]}{.status.containerStatuses[0].imageID}{"\n"}{end}'
```

### Custom columns
```shell
$ kubectl get pods \
  -o custom-columns='NAME:metadata.name,IMAGES:spec.containers[*].image'
```

## Proxy
- To open a connexion (expose a port) between the local machine and the Server API
- ... for a short time (during debug for example)
- for example the [Kubernetes Dashboard](./tools/dashboard.md)
```shell
$ kubectl proxy
$ curl http://localhost:8080/api/v1/namespaces/default/services/www:80/proxy/
```
- See [Service, ClusterIP](../service/clusterip.md)

## kubectl-aliases
- https://github.com/ahmetb/kubectl-aliases

## Plugins
- Executable file to extend `kubectl`
- Should be in the path
- https://github.com/ahmetb/krew: package manager for kubectl plugins
Sample:
```shell
#!/bin/bash

# optional argument handling
if [[ "$1" == "version"]]
then
    echo "1.0.0" && exit 0
fi

# optional argument handling
if [[ "$1" == "config"]]
then
    echo $KUBECONFIG && exit 0
fi

echo "I am a plugin named kubectl-foo"
```
Command:
```shell
$ kubectl foo
$ kubectl foo version
$ kubectl foo config
```
