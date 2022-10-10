# Kubernetes Service / NodePort

- Child of [Service](..)
- To expose a Pod outside a cluster
- By assigning a (same) given port to each node of a cluster  
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Services/service_NodePort.md

### Config
```yaml
apiVersion: v1
kind: Service
metadata:
  name: vote-np
spec:
  selector:
    app: vote             # Select all Pods having label 'app' with value 'vote'
  type: NodePort          # FROM OUTSIDE THE CLUSTER VIA nodePort (below)             <== (1/2)
  ports:
    - port: 80            # Arrive at port 80 of the service
      targetPort: 80      # Forwarded on the port 80 of a Pod
      nodePort: 31000     # EXPOSED PORT                                              <== (2/2)
```
- `NodePort/service.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: vote
  labels:
    app: vote              # A Pod having label 'app' with value 'vote'
spec:
  containers:
    - name: vote
      image: instavote/vote
      ports:
        - containerPort: 80
```
- `ClusterIp/pod.yaml`

### Command
```shell
$ minikube start
$ kubectl apply -f ../config/ClusterIp/pod.yaml
$ kubectl apply -f ../config/NodePort/service.yaml

$ kubectl get pod,service
$ kubectl get svc/vote -o yaml
$ kubectl describe svc/vote

$ kubectl get nodes -o wide

curl http://<EXTERNAL-IP>:31000

$ kubectl delete po/vote svc/vote-np
$ minikube delete
```
