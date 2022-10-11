# Kubernetes Service / ClusterIP

- Part of [Service](./README.md)
- To expose a Pod only **INSIDE** a cluster
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Services/service_ClusterIP.md

### Config
```yaml
apiVersion: v1
kind: Service
metadata:
  name: vote
spec:
  selector:
    app: vote             # Select all Pods having label 'app' with value 'vote'
  type: ClusterIP         # = Default value => ONLY INSIDE THE CLUSTER
  ports:
    - port: 80            # Arrive at port 80 of the service
      targetPort: 80      # Forwarded on the port 80 of a Pod
```
- `config/service/ClusterIp/service.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vote
  labels:
    app: vote           # A Pod having label 'app' with value 'vote'
spec:
  containers:
    - name: vote
      image: instavote/vote
      ports:
        - containerPort: 80
```
- `config/service/ClusterIp/pod.yaml`

### Command
```shell
$ minikube start
$ kubectl apply -f ../config/service/ClusterIp/pod.yaml
$ kubectl apply -f ../config/service/ClusterIp/service.yaml

$ kubectl get pod,service
NAME       READY   STATUS    RESTARTS      AGE
pod/debug  1/1     Running   1 (10m ago)   11m
pod/vote   1/1     Running   0             12m
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   12m
service/vote         ClusterIP   10.109.113.93   <none>        80/TCP    11m
$ kubectl get svc/vote -o yaml
$ kubectl describe svc/vote

...

$ kubectl delete po/vote po/debug svc/vote
$ minikube delete
```

### Verify from another Pod
```shell
$ kubectl run -ti debug --image=alpine
/ apk add -u curl
/ curl http://vote
```

### Verify with `port-forward`
```shell
$ kubectl port-forward service/vote 8080:80
$ curl http://localhost:8080
```

### Verify with the kubernetes proxy
```shell
$ kubectl proxy
$ curl http://localhost:8001/api/v1/namespaces/default/services/vote:80/proxy/
```
