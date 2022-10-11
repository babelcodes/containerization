# Managed clusters in production

- Part of [Kubernetes](./README.md)
- https://kubernetes.io/fr/docs/setup/
- https://www.udemy.com/course/la_plateforme_k8s/learn/lecture/14793064?start=15#overview


## GKE - Google Kubernetes Engine
- Online: https://console.cloud.google.com
- CLI: [gcloud](https://cloud.google.com/sdk/docs/install)
```shell
$ gcloud init
$ glcoud container clusters create ...
```

## AKS - Azure Kubernetes/Container Service
- Online: https://portal.azure.com/
- CLI: [az](https://learn.microsoft.com/fr-fr/cli/azure/install-azure-cli)
```shell
$ az group create ...
$ az aks create ...
```

## Digital Ocean
- Online: https://www.digitalocean.com/
- CLI: https://docs.digitalocean.com/reference/doctl/how-to/install/
- https://www.udemy.com/course/la_plateforme_k8s/learn/lecture/14795714#overview
```shell
$ doctl k8s cluster create ...
```


## OVH


## Tools

### Kubeadm
> Kubeadm is a tool built to provide best-practice "fast paths" for creating Kubernetes clusters.
- https://github.com/kubernetes/kubeadm
- No default solution for networking (can use `Weave Net`).

Workshop
- https://gitlab.com/lucj/k8s-exercices/-/blob/master/Installation/kubeadm.md
```shell
###
### CREATE MASTER
###
$ multipass launch -n control-plane -m 2G -c 2 -d 10G

###
### CREATE WORKER
###
$ multipass launch -n worker -m 2G -c 2 -d 10G
$ multipass shell control-plane

###
### SETUP MASTER WITH kubeadm (bin and config)
###
@control-plane$ curl -sSL https://luc.run/kubeadm/master.sh | bash
kubeadm join 192.168.64.11:6443 --token kcizwu.4t66dfg1pketp3yz \
	--discovery-token-ca-cert-hash sha256:6f27654496dab5235f1381d1eecdcc50fe60469af9ca1f9c38e592b2025890d7 
@control-plane$ sudo kubeadm token create --print-join-command
@control-plane$ mkdir -p $HOME/.kube
@control-plane$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
@control-plane$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

$ multipass shell worker

###
### SETUP WORKER WITH kubeadm (bin, config and join)
###
@worker$ curl -sSL https://luc.run/kubeadm/worker.sh | bash
@worker$ sudo kubeadm join 192.168.64.11:6443 --token kcizwu.4t66dfg1pketp3yz \
	--discovery-token-ca-cert-hash sha256:6f27654496dab5235f1381d1eecdcc50fe60469af9ca1f9c38e592b2025890d7 

@control-plane$ kubectl get nodes
NAME            STATUS     ROLES           AGE     VERSION
control-plane   NotReady   control-plane   9m38s   v1.25.2
worker          NotReady   <none>          63s     v1.25.2
@control-plane$ kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml
@control-plane$ kubectl get nodes
NAME            STATUS     ROLES           AGE   VERSION
control-plane   NotReady   control-plane   18m   v1.25.2
worker          Ready      <none>          10m   v1.25.2
@control-plane$ kubectl get nodes
NAME            STATUS   ROLES           AGE   VERSION
control-plane   Ready    control-plane   19m   v1.25.2
worker          Ready    <none>          10m   v1.25.2

###
### GET GENERATED CONFIG to communicate with master from local
###
$ multipass exec control-plane -- sudo cat /etc/kubernetes/admin.conf > kubeconfig
$ export KUBECONFIG=$PWD/kubeconfig
$ kubectl get nodes
NAME            STATUS   ROLES           AGE   VERSION
control-plane   Ready    control-plane   22m   v1.25.2
worker          Ready    <none>          13m   v1.25.2
```

### kops
> kops will not only help you create, destroy, upgrade and maintain production-grade, highly available, Kubernetes cluster, but it will also provision the necessary cloud infrastructure.
- https://github.com/kubernetes/kops

### kubespray
> Deploy a Production Ready Kubernetes Cluster
- https://github.com/kubernetes-sigs/kubespray

### Rancher
> From datacenter to cloud to edge, Rancher lets you deliver Kubernetes-as-a-Service.
- https://www.rancher.com/

### Pharos
> The simple, solid, certified Kubernetes distribution that just works.
- https://github.com/kontena/pharos-docs

### Terraform + Ansible
> Provision, change, and version resources on any environment.
- https://www.terraform.io/

    > Ansible delivers simple IT automation that ends repetitive tasks and frees up DevOps teams for more strategic work.
- https://www.ansible.com/
