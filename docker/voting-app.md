# Voting App

> Sample App often used in demos and presentations

- https://github.com/dockersamples/example-voting-app
- Maintained by Docker
- 5 services, different languages and databases
- Several files in `docker-compose` format
  - A Service
  - Also, [Kubernetes specifications](https://github.com/dockersamples/example-voting-app/tree/master/k8s-specifications) for Service and Deployment

![](https://github.com/dockersamples/example-voting-app/raw/master/architecture.png)



## With Kubernetes

- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Pratique-VotingApp/voting_app.md
- https://github.com/dockersamples/example-voting-app/tree/master/k8s-specifications
   - A Deployment file for each of the 5 microservices
   - A Service file for each of the 5 microservices
     - Except for the worker as it takes from Redis to push into Postgre without needing to be called / exposed
- Use [Minikube](../kubernetes/minikube.md)

```shell
$ minikube start

$ kubectl create -f ./k8s-specifications       ## <!> Provide the folder, not a single file!
$ kubectl get po,deploy,svc
$ minikube ip                                  ## Get the IP of the Minikube VM...
$ open http://$(minikube ip):31000             ## ... to open VOTING app on this IP with port 31000
$ open http://$(minikube ip):31001             ## ... to open RESULT app on this IP with port 31001

$ minikube delete
```
