# Kubernetes Namespace

> To segment a cluster, to share resources

- Part of [Kubernetes](./README.md)
- 3 levels:
  - default
  - `kube-public`
  - `kube-system`
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Namespace/namespace.md

Namespace configuration:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    name: development
```
- ./config/namespace/dev.namespace.yaml

Pod configuration to attach to a namespace:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  namespace: development     # <<< Attach this pod to the namespace
spec:
  containers:
    - name: nginx
      image: nginx:1.12.2
```
- ./config/namespace/dev.pod.yaml

```shell
## SETUP
$ minikube start

## CREATE THE NAMESPACE
$ kubectl create -f ./config/namespace/dev.namespace.yaml
## $ kubectl create namespace development

## CREATE THE POD
$ kubectl create -f ./config/namespace/dev.pod.yaml

## MONITORING
$ kubectl get po
No resources found in default namespace.
$ kubectl get po --namespace=development
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          108s
$ kubectl get po --all-namespaces
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
development   nginx                              1/1     Running   0          2m31s
...

## A DEPLOYMENT with 2 replicas in the namespace development
### $ kubectl run www --namespace development --replicas=2 --image nginx:1.12.2
$ kubectl create deploy www --namespace development --replicas=2 --image nginx:1.12.2
$ kubectl get deploy --namespace developments
$ kubectl get po --namespace developments

##
## CHANGE NAMESPACE IN CONTEXT
##
$ kubectl config view
...
contexts:
- context:
    cluster: minikube
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
...

$ kubectl config current-context
minikube

$ kubectl config set-context $(kubectl config current-context) --namespace=development

$ kubectl config view
...
    namespace: development
...

### $ kubectl run w3 --image nginx:1.12.2
$ kubectl create deploy w3 --image nginx:1.12.2
deployment.apps/w3 created

$ kubectl get deploy
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
w3     1/1     1            1           7s

$ kubectl get deploy --namespace development
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
w3     1/1     1            1           24s

$ kubectl get deploy --namespace default
No resources found in default namespace.

## CLEANUP
$ kubectl delete namespace/development
$ minikube delete
```

## Add quotas to a namespace
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Namespace/ResourceQuota.md

## LimitRange to control Pods
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Namespace/LimitRange.md
