# Kubernetes Deployment

> Manage a pool of identical Pods (update & rollback), with a count of replicas

- Part of [Kubernetes](./README.md)

Table of content:
1. [Overview](#overview)
1. [With configuration](#with-configuration)
1. [With imperative approach](#with-imperative-approach)
1. [Workshop](#workshop)
1. [Strategies](#strategies)
   1. [Rolling Update](#rolling-update)
1. [Sample](#sample)
1. [Horizontal scaling](#horizontal-scaling)


## Overview
Abstraction layers:
- Deployment
  - Replica Set
    - Pod

2 ways for creating a Deployment:d
```shell
$ kubectl apply -f deploy.yaml
$ kubectl create deploy vote --image instavote/vote
```
## With configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vote
spec:
  replicas: 3         # REPLICAS : Count of Pods
  selectors:          # SELECTORS: Matching Pods
    matchLabels:
      app: vote
  template:           # TEMPLATE : Specification of Pods to launch
    metadata:
      labels:
        app: vote
    spec:
      containers:
      - name: vote
        image: instavote/vote
        ports:
        - containerPorts: 80
```
- `deploy.yaml`

```shell
$ kubectl apply -f deploy.yaml
$ kubectl get deployment,rs,pod         ## rs stands for ReplicaSet
```

## With imperative approach
```shell
$ kubectl create deploy vote \
  --image instavote/vote     \
  --dry-run=client
  -o yaml
$ kubectl get deployment,rs,pod         ## rs stands for ReplicaSet
```


## Workshop
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Deployment/deployment_ghost.md


## Strategies
- https://blog.container-solutions.com/deployment-strategies
- Canary
  - Big part of requests handle by v1, and when validated all are migrated to v2
- Blue-green
- Recreate
- Rolling update

### Rolling update
- Gradual: replicas gradually migrated, without human intervention
- Triggered each time the configuration is updated
```
─ ─ ─ ─ ─ ─┌────┐ ─ ─ ─ ─ ─ ─ ─┌────┐ ─ ─ ─ ─ ─ ─ ─ ┌────┐─ ─ ─ ─ ─ ─ ─ ─▲─
           │ v2 │              │ v2 │               │ v2 │               │ maxSurge: 1
┌────┐─ ─ ┌┴───┬┘ ─ ─┌────┐ ─ ─├────┤ ─ ─┌────┐ ─ ─ ├────┤─ ─ ┌────┐─ ─ ─│─
│ v1 │    │ v1 │     │ v2 │    │ v2 │    │ v2 │     │ v2 │    │ v2 │     ▼ maxUnavailable: 0
├────┤    ├────┤    ┌┴───┬┘   ┌┴───┬┘    ├────┤     ├────┤    ├────┤     
│ v1 │    │ v1 │    │ v1 │    │ v1 │     │ v2 │     │ v2 │    │ v2 │
├────┤    ├────┤    ├────┤    ├────┤    ┌┴───┬┘    ┌┴───┬┘    ├────┤
│ v1 │    │ v1 │    │ v1 │    │ v1 │    │ v1 │     │ v1 │     │ v2 │
└────┘    └────┘    └────┘    └────┘    └────┘     └────┘     └────┘
                                                                                  
    ────────────────────────────────────────────────────────────▶ Update in time   
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: www
spec:
  strategy:
    role: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Count of ADDITIONAL replicas
      maxUnavailable: 0  # Count of FEWER replicas 
```

With imperative approach:
```shell
$ kubectl set image deploy/vote vote=instavote/vote:movies --record
```

History:
```shell
$ kubectl rollout undo deploy/vote
$ kubectl rollout undo deploy/vote --to-revision=X
```

Enforce update:
```shell
$ kubectl rollout restart deploy/vote
$ kubectl get pods -w
```

## Sample
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Deployment/rollout_rollback.md
```shell
##
## SETUP
## 
$ minukube start

##
## DEPLOYMENT: START
## 
$ kubectl apply -f ./config/deployment/nginx-1.14.yaml     ## --record=true
$ kubectl get deployment,rs,pod
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/www   0/3     3            0           21s
NAME                             DESIRED   CURRENT   READY   AGE
replicaset.apps/www-566469bb77   3         3         0       21s
NAME                       READY   STATUS              RESTARTS   AGE
pod/www-566469bb77-lkf2q   0/1     ContainerCreating   0          21s
pod/www-566469bb77-qgqhr   0/1     ContainerCreating   0          21s
pod/www-566469bb77-qnm6x   0/1     ContainerCreating   0          21s

$ kubectl get pod/www-566469bb77-lkf2q -o yaml 

##
## DEPLOYMENT: UPDATE (through config)
## 
$ kubectl apply -f ./config/deployment/nginx-1.16.yaml     ## --record=true
deployment.apps/www configured

$ kubectl get deployment,pod
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/www   3/3     1            3           4m59s
NAME                       READY   STATUS              RESTARTS   AGE
pod/www-566469bb77-lkf2q   1/1     Running             0          4m59s     # <<< will be removed!
pod/www-566469bb77-qgqhr   1/1     Running             0          4m59s     # <<< will be removed!
pod/www-566469bb77-qnm6x   1/1     Running             0          4m59s     # <<< will be removed!
pod/www-675c66db67-p6q8m   0/1     ContainerCreating   0          21s       # <<< STARTING...

$ kubectl get deployment,pod
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/www   3/3     3            3           5m29s
NAME                       READY   STATUS    RESTARTS   AGE
pod/www-675c66db67-kntx4   1/1     Running   0          24s
pod/www-675c66db67-p6q8m   1/1     Running   0          51s                 # <<< ...STARTED!
pod/www-675c66db67-r8psg   1/1     Running   0          26s

##
## DEPLOYMENT: UPDATE (through commandline)
## 
$ kubectl set image deploy/www www=nginx:1.18 --record # --record to tag for history
$ kubectl get deployment,pod
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/www   3/3     1            3           9m24s
NAME                       READY   STATUS              RESTARTS   AGE
pod/www-675c66db67-kntx4   1/1     Running             0          4m19s     # <<< will be removed!
pod/www-675c66db67-p6q8m   1/1     Running             0          4m46s     # <<< will be removed!
pod/www-675c66db67-r8psg   1/1     Running             0          4m21s     # <<< will be removed!
pod/www-78994fd9df-ztc2m   0/1     ContainerCreating   0          3s        # <<< STARTING...

$ kubectl get deployment,pod
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/www   3/3     3            3           12m
NAME                       READY   STATUS    RESTARTS   AGE
pod/www-78994fd9df-7c44j   1/1     Running   0          2m11s
pod/www-78994fd9df-nt8xx   1/1     Running   0          2m8s
pod/www-78994fd9df-ztc2m   1/1     Running   0          2m40s              # <<< ...STARTED!

##
## ROLLOUT: MONITORING & MAINTENANCE
## 
$ kubectl rollout history deploy/www
deployment.apps/www 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         kubectl set image deploy/www www=nginx:1.18 --record=true

$ kubectl rollout undo deploy/www --to-revision=1
deployment.apps/www rolled back

$ kubectl get deployment,pod
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/www   3/3     1            3           18m
NAME                       READY   STATUS              RESTARTS   AGE
pod/www-566469bb77-69q54   0/1     ContainerCreating   0          2s
pod/www-78994fd9df-7c44j   1/1     Running             0          8m51s
pod/www-78994fd9df-nt8xx   1/1     Running             0          8m48s
pod/www-78994fd9df-ztc2m   1/1     Running             0          9m20s

$ kubectl get pod/www-566469bb77-lkf2q -o yaml
...
spec:
  containers:
  - image: nginx:1.14
...

$ kubectl rollout history deploy/www
deployment.apps/www 
REVISION  CHANGE-CAUSE
2         <none>
3         kubectl set image deploy/www www=nginx:1.18 --record=true
4         <none>

##
## CLEANUP
## 
$ kubectl delete deploy www
$ minikube delete
```


## Horizontal scaling
- Both through config and/or commandline with option `--replicas` as below
```shell
$ kubectl create deploy www --image=nginx:1.16
$ kubectl scale deploy/www --replicas=5
```

### HorizontalPodAutoscaler (HPA)
- Can be used on a Deployment or a ReplicaSet
- Decrease of Pods count is slower than increase
By config:
```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: www
spec:
  scaleTargetRef:                        # Monitored object
    apiVersion: apps/v1
    kind: Deployment
    name: www
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50     # Condition to trigger
##
## $ kubectl apply -f hpa.yaml
##
```
Or by command:
```shell
$ kubectl autoscale \
  deploy www \
  --min=2 \
  --max=10 \
  --cpu-percent=50
```
Then monitor:
```shell
$ kubectl get hpa -w
```
- A metrics server must be installed before
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Deployment/HorizontalPodAutoscaler.md
