# Kubernetes Service

- Expose a Pod of an application through the network
- `kube-proxy` responsible for load-balancing
- Several types:
  - [ClusterIP](./clusterip.md) (default): To expose a Pod only **INSIDE** a cluster
  - `NodePOrt`: to expose to external of cluster
  - `LoadBalancer`: integration with a Cloud Provider
  - `ExternalName`: map the service to a DNS
