# Kubernetes Service

- Expose a Pod of an application through the network
- `kube-proxy` responsible for load-balancing
- Several types:
  - [ClusterIP](./clusterip.md) (default): To expose a Pod only **INSIDE** a cluster
  - [NodePort](./nodeport.md): To expose to external of cluster
  - `LoadBalancer`: integration with a Cloud Provider
    - https://www.udemy.com/course/la_plateforme_k8s/learn/lecture/17790174#overview
  - `ExternalName`: map the service to a DNS

## Via imperative commands

- Quick, but can not use all the options 

### Expose

```shell
$ kubectl expose pod vote \
  --type=NodePort \
  --port=8080 \
  --target-port=80 \
  --dry-run=client \
  -o yaml
```
Generates the following configuration:
```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: vote
  name: vote
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 80
  selector:
    app: vote                   # <== GENERATED SELECTOR based on the pod name
  type: NodePort
status:
  loadBalancer: {}
```

### Create

```shell
$ kubectl create service \
  nodeport \
  vote \
  --tcp 8080:80 \
  --dry-run=client \
  -o yaml
```
Generates the following configuration:
```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: vote
  name: vote
spec:
  ports:
    - name: 8080-80
      port: 8080
      protocol: TCP
      targetPort: 80
  selector:
    app: vote                   # <== GENERATED SELECTOR based on the pod name
  type: NodePort
status:
  loadBalancer: {}
```

### Run

- To create a Pod with its Service

```shell
$ kubectl run db \             # <== GENERATE THE POD
  --image=mongo:4.2 \
  --port=27017 \
  --expose \                   # <== GENERATE ALSO THE SERVICE
  --dry-run=client \
  -o yaml
```
Generates the following configuration for the **Pod**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: db
  name: db
spec:
  containers:
  - image: mongo:4.2
    name: db
    ports:
    - containerPort: 27017
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```
and the following for the **Service**:
```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  name: db
spec:
  ports:
    - port: 27017
      protocol: TCP
      targetPort: 27017
  selector:
    run: db
status:
  loadBalancer: {}
```

## Commands

Create a service:
```shell
$ kubectl apply -f SERVICE.yaml
$ kubectl expose ...
$ kubectl create service ...
```

List services:
```shell
$ kubectl get service
$ kubectl get svc

NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        77m
vote         ClusterIP   10.109.113.93    <none>        80/TCP         76m
vote-np      NodePort    10.102.184.221   <none>        80:31000/TCP   34m
```

Get main information of a service:
```shell
$ kubectl get svc/SERVICE_NAME

NAME   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
vote   ClusterIP   10.109.113.93   <none>        80/TCP    75m
```

Get details of a service:
```shell
$ kubectl describe svc SERVICE_NAME

Name:              vote
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=vote
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.109.113.93
IPs:               10.109.113.93
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         172.17.0.3:80
Session Affinity:  None
Events:            <none>
```

Delete a service:
```shell
$ kubectl delete svc/SERVICE_NAME
```
