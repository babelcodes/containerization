# Kubernetes Pod

Infrastructure:
```
     ┌───────────────────────────────────────────────┐
     │ Cluster                                       │
     │                                               │
     │ ┌────────────────────────────────────┐        │
     │ │ Node                               │        │
     │ │                                    │        │
     │ │ ┌─────────────────────────┐        │        │
     │ │ │ Pod (network & storage) │        │        │
     │ │ │                         │        │        │
     │ │ │ ┌──────────────┐        │        │        │
     │ │ │ │ Container    │        │        │        │
     │ │ │ │              │        │        │        │
     │ │ │ └──────────────┘        │        │        │
     │ │ └─────────────────────────┘        │        │
     │ └────────────────────────────────────┘        │
     └───────────────────────────────────────────────┘
```

Application:
```
       ┌────────────────────────────────────┐ 
       │ Application                        │ 
       │                                    │ 
       │ ┌─────────────────────────┐        │ 
       │ │ Pod (Spec)              │        │
       │ │ = Business Service (MS) │        │ 
       │ │ ┌──────────────┐        │        │ 
       │ │ │ Replicas     │        │        │ 
       │ │ │              │        │        │ 
       │ │ └──────────────┘        │        │ 
       │ └─────────────────────────┘        │ 
       └────────────────────────────────────┘ 
```

- Smallest applicative unit running on a cluster
- Group of containers sharing network and storage
- In a single isolation context
- Count of replicas = count of instances of this pod on the cluster
- Can deploy a microservice on N pods

![](https://d33wubrfki0l68.cloudfront.net/fe03f68d8ede9815184852ca2a4fd30325e5d15a/98064/docs/tutorials/kubernetes-basics/public/images/module_03_pods.svg)

## Configuration
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: www
    image: nginx:1.12.2
```

## Commands
Two ways to create a Pod.


### Imperative commands (debug / dev)
```shell
$ kubectl run www --image nginx:1.16

$ kubectl run www --image nginx:1.16 --dry-run=cllient -o yaml    # dry-run to simulate the creation and get the result 
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: db
  name: db
spec:
  containers:
  - image: nginx:1.16
    name: db
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
$ kubectl get pod   # Always the same count of pod than before
```

### Specification file
```shell
$ kubectl create -f POD_SEPC.yml
$ kubectl get pod
$ kubectl describe pod POD_NAME
$ kubectl logs POD_NAME [-c CONTAINER_NAME]
$ kubectl exec POD_NAME [-c CONTAINER_NAME] -- COMMAND

$ kubectl create -f nginx-pod.yml
$ kubectl get pods
$ kubectl exec www -- nginx -v
$ kubectl exec -ti www -- /bin/bash
$ kubectl describe po/www
$ kubectl delete po/www

$ kubectl port-forward www 8080:80 && open localhosst:8080

$ docker ps | grep www
```

Samples:
```shell
$ cat config/pod.k8s.yml
$ kubectl create -f config/pod.k8s.yml
pod/www created
$ kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
www    1/1     Running   0          100s
$ kubectl describe po/www
$ kubectl port-forward www 8080:80

$ cat config/pod.k8s.debug.yml
$ kubectl create -f config/pod.k8s.debug.yml
$ kubectl get po
NAME    READY   STATUS    RESTARTS   AGE
debug   1/1     Running   0          74s
www     1/1     Running   0          6m53s

$ kubectl exec -ti debug -- sh
/ ping 172.17.0.3

$ kubectl delete po/debug po/www
```

Workshop:
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Pod/pod_whoami.md
```shell
$ cat config/pod.k8s.workshop.yml
$ create -f config/pod.k8s.workshop.yaml
$ kubectl get po
$ kubectl describe po/whoami
$ kubectl port-forward whoami 8888:80
$ kubectl delete po/whoami
```

## Multi-container (with Wordpress)
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Pod/pod_wordpress.md
```shell
$ cat config/pod.k8s.wordpress.yml
$ kubectl create -f config/pod.k8s.wordpress.yml
$ kubectl get po
NAME   READY   STATUS    RESTARTS      AGE
wp     2/2     Running   1 (13s ago)   61s
$ kubectl port-forward wp 8080:80 && open localhost:8080
### Note: si vous utilisez une machine virtuelle intermédiaire pour accéder à votre cluster, 
### vous pourrez utiliser l'option --address 0.0.0.0 pour la commande port-forward afin de permettre 
### l'accès depuis toutes les interfaces réseau de votre machine.
$ kubectl port-forward --address 0.0.0.0 wp 8080:80
$ kubctl delete po/wp
```

## Scheduler
- Select the node to deploy the Pod
- Made by `kube-scheduler`
- https://www.udemy.com/course/la_plateforme_k8s/learn/lecture/14676266#overview
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Pod/pod_scheduling.md
```shell
$ kubectl run www --image=nginx:1.16-alpine --restart=Never
pod/www created
$ kubectl describe pod www
```

### Directives
- `spec/nodeSelector`
- `spec/affinity/nodeAffinity` (hard constraint / `requiredDuring...` and soft constraint / `preferredDuring...`)
- `spec/affinity/podAffinity` and `spec/affinity/podAntiAffinity` (`topologeyKey`) 
- `spec/taints/effect` and `spec/tolerations/effect` 
- `spec/containers/resources` (minimal limit / `requests:` and maximal limit / `limits:`)
- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

### Labels
First set a label:
```shell
$ kubectl label nodes node1 disktype=ssd
$ kubectl describe node/node1 -o yaml
...
metadata:
  labels:
    ...
    disktype: ssd
```
Then use this label as selector (`mysql.pod.yaml`):
```yaml
...
spec:
  containers:
    ...
  nodeSelector:
    disktype: ssd
```

## Quiz

Quelle commande permet de lancer un shell sh intéractif dans le container nommé nginx dans le Pod nommé  www ?
- `$kubectl exec -ti www -c nginx -- sh`
