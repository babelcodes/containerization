# Docker Swarm

> The clustering and orchestration solution from Docker
> - to manage a hosts cluster
> - orchestrate the services of this cluster

Table of content
- [Introduction](#introduction)
- [RAFT - Distributed Consensus](#raft---distributed-consensus)
- [Node](#node)
- [Commands](#commands)
- [Sample](#sample)
- [Service](#service)
- [Secret](#secret)
- [Config](#config)
- [Stack](#stack)
- [TICK](#tick)
- [Routing Mesh](#routing-mesh)
- [Backup & Restore](#backup--restore)
- [Fault tolerance](#fault-tolerance)
- [Monitoring](#monitoring)
- [Quiz](#Quiz)


## Introduction

![](https://gitlab.com/lucj/docker-exercices/-/raw/master/11.Swarm/images/swarm1.png)

https://docs.docker.com/engine/swarm/

- See [Docker](./README.md)
- Since v1.12, more easy (June, 2016)
- Orchestration integrated to the deamon 
- A Swarm cluster, orchestrator, as [Kubernetes](../kubernetes)
- Define applications with [Docker Compose](./compose.md)
- Reconciliation loop
- Handle (rolling) updates
- Load balancing (VIP)
- Crypted data
- Nodes workers vs. managers
- A Swarm is secured (logs encryption, TLS communication between nodes, certificates rolling)

Primitives
- Node
- Service
- Stack (services group)
- Secret

Commands

```shell
$ docker swarm --help

$ docker swarm init
$ docker swarm join
```


## RAFT - Distributed Consensus

- http://thesecretlivesofdata.com/raft/
  - [The Raft Paper](https://raft.github.io/raft.pdf)
  - [Raft web site](https://raft.github.io/)
- When we have several "server" nodes
- A node can be in 1 of 3 states:
  - `Follower`, the default starting state
  - `Candidaite`, the state if don't hear a `Leader`
  - `Leader`
- Sequence for each node:
  - Start as `Follower`
  - If do not hear a `Leader` become a `Candidate`
  - Request vote from others
  - Receive votes
  - Become the `Leader` if receive vote from a majority (Leader Election)
- All changes to the system go through the `Leader`
- Log Replication
  - Each change is added as an entry in the node's log, as uncommitted
  - First, the `Leader` replicates the entry to the `Follower`s nodes
  - Then, `Leader` waits until a majority of nodes have written the entry
  - Then, the entry is committed on the `Leader`
  - Then, `Leader` notifies the `Followers` that the entry is committed
  - The cluster has now come to consensus about the system state
- Raft (2 timeout settings to control elections)
  - `Election timeout` is the time a `Follower` waits until becoming a `Candidate`
    - Randomized between 150ms and 300ms
  - `Hearbeat timeout` is the interval in which Append Entries messages are sent to `Follower`
- Heartbeats are sent on regular basis
  - Including lifecycle beat
  - And change message
- [RAFT go deeper](https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/raft-logs.md)


## Node

- Machine included in the Swarm
- Can be
  - `Manager`
    - Schedule and orchestrate containers, if Leader
    - Manage the cluster state
    - RAFT
    - Save the Swarn state in `/var/lib/docker/swarm`
  - `Worker`
    - Execute containers
  - by default, a manager is also a worker
- States (availability)
  - `Active`, tasks can be assigned (by managers)
  - `Pause`, new task can not be assigned and existing tasks are unchanged
  - `Drain`, new task can not be assigned and existing tasks are stopped and launched on other nodes

### Commands
- Must be addressed to a `Manager` node
  - `inspect`
  - `demote` / `promote`
  - `ls` / `rm` / `update`
```shell
$ docker node --help

Usage:  docker node COMMAND

Manage Swarm nodes

Commands:
  demote      Demote one or more nodes from manager in the swarm
  inspect     Display detailed information on one or more nodes
  ls          List nodes in the swarm
  promote     Promote one or more nodes to manager in the swarm
  ps          List tasks running on one or more nodes, defaults to current node
  rm          Remove one or more nodes from the swarm
  update      Update a node

Run 'docker node COMMAND --help' for more information on a command.
```


## Commands

### Init a Swarm from a node
- The command displays the command to launch from other node to join them to the swarm
- [La plateforme Docker | Udemy - Création d'un Swarm](https://www.udemy.com/course/la-plateforme-docker/learn/lecture/13215980#overview)
- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/swarm-creation-local.md
```shell
@node1$ docker swarm init --advertise-addr 192.168.99.100
To add a worker to this swarm, run the following command: docker swarm join --token ...
To add a manager to this swarm, run docker swarm join-token manager ...

@node1$ docker node ls                   # MUST BE LAUNCHED FROM A MANAGER
ID     HOSTNAME     STATUS     AVAILABILITY     MANAGER     STATUS
```

### Attach a worker
```shell
@node2$ docker swarm join --token ...
```

### Attach a manager
```shell
@node1$ docker swarm join-token manager  # MUST BE LAUNCHED FROM A MANAGER
To add a manager to this swarm, run the following command: docker swarm join --token ...

@node3$ docker swarm join --token ...    # MUST BE LAUNCHED FROM the manager candidate (node *3*)

@node1$ docker node ls                   # MUST BE LAUNCHED FROM A MANAGER
ID          HOSTNAME     STATUS     AVAILABILITY     MANAGER     STATUS
1m9...      node3        Ready      Active           Reachable
lf2...  *   node1        Ready      Active           Leader
pes...      node2        Ready      Active           

@node1$ docker node inspect -f '{{ json .Spec }}' node1
{
    "Labels": {},
    "Role": "manager",
    "Availability": "active"
}
```

### Manager: Promote (to) & demote (from)
```shell
@node1$ docker node demote node1         # MUST BE LAUNCHED FROM A MANAGER (node 1)
                                         # The remaining manager (node3) is automatically promoted as LEADER
@node3$ docker node promote node2        # MUST BE LAUNCHED FROM A MANAGER (node *3*)

@node2$ docker node ls                   # MUST BE LAUNCHED FROM A MANAGER (node *2*)
ID          HOSTNAME     STATUS     AVAILABILITY     MANAGER     STATUS
1m9...      node3        Ready      Active           Leader
lf2...  *   node1        Ready      Active           
pes...      node2        Ready      Active           Reachable
```

### Availability
- Among: `Active`, `Pause`, `Drain`
- Manage task deployment on a node 
```shell
@node1$ docker node update --availability pause node2
@node1$ docker node update --availability drain node2
@node1$ docker node update --availability active node2
@node1$ docker node inspect -f '{{ json .Spec }}' node2
{
    "Labels": {},
    "Role": "worker",
    "Availability": "active"
}
```

### Labels
- Facilitate nodes management, as tags
```shell
@node1$ docker node inspect -f '{{ json .Spec.Labels }}' node1
{}

@node1$ docker node update --label-add Memcached=true node1
@node1$ docker node inspect -f '{{ json .Spec.Labels }}' node1 | jq .
{
    "Memcached": "true"
}
```

### Machines

- See [Docker Machine](./machine.md)


## Sample

- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/swarm-creation-local.md
- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/swarm-creation-DigitalOcean.md

Create virtual machines (future nodes):
```shell
$ docker-machine create --driver virtualbox node1
$ docker-machine create --driver virtualbox node2
$ docker-machine create --driver virtualbox node3

# $ docker-machine regenerate-certs node3 
# $ docker-machine restart node3
```

Initialize the Swarm (connected onto the node1):
```shell
$ docker-machine ssh node1
@node1$ docker swarm init
@node1$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
hxe06csr1ffvedr6hqcsyypau *   node1               Ready               Active              Leader              19.03.12
```

Attach other nodes as workers (connected onto them):
```shell
$ docker-machine ssh node2
@node2$ docker swarm join --token SWMTKN-1-56t0awp55yflnr7oka9l7d7z7swhbervijmzze55b3wn4n2chy-93ddiva70ww50fmsoavrw1yom 192.168.99.104:2377

$ docker-machine ssh node3
@node3$ docker swarm join --token SWMTKN-1-56t0awp55yflnr7oka9l7d7z7swhbervijmzze55b3wn4n2chy-93ddiva70ww50fmsoavrw1yom 192.168.99.104:2377
@node1$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
hxe06csr1ffvedr6hqcsyypau *   node1               Ready               Active              Leader              19.03.12
```

Check system (from manager node1):
```shell
@node1$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
d0ygaohomid6b9mttlr8i4b6r *   node1               Ready               Active              Leader              19.03.12
0myxlr2lbmnr4fl8d9curhjhh     node2               Ready               Active                                  19.03.12
xym9kgs3yp9bnnd3zf3sc3hxs     node3               Ready               Active                                  19.03.12
```

Promote workers (from manager node1):
```shell
@node3$ docker node promote node2
Error response from daemon: This node is not a swarm manager. Worker nodes can't be used to view or modify cluster state. 
Please run this command on a manager node or promote the current node to a manager.

@node1$ docker node promote node2
Node node2 promoted to a manager in the swarm.

@node1$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
d0ygaohomid6b9mttlr8i4b6r *   node1               Ready               Active              Leader              19.03.12
0myxlr2lbmnr4fl8d9curhjhh     node2               Ready               Active              Reachable           19.03.12
xym9kgs3yp9bnnd3zf3sc3hxs     node3               Ready               Active                                  19.03.12

@node2$ docker node demote node2                                                                                                               
Manager node2 demoted in the swarm.
```


## Service

- Since 1.12
- Launch the containers
- Mode `replicated` or `global`
- Service discovery
- Publish port / routing mesh (ex: can access to a webapp on each node even if no replicas)

Configuration
- Used image
- Deployment mode
- Exposed ports
- Secrets
- Boot strategy
- Deployment constraints
- Updates
- Resources
- Health check
- https://docs.docker.com/engine/reference/commandline/service_create/

Tasks
- A `service`
  - Launches N `tasks` (replicas) and for each:
    - Is deployed on a `mode`
    - Executes a `container`

![](https://docs.docker.com/engine/swarm/images/services-diagram.png)
- https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/

### Commands
```shell
$ docker service --help

Commands:
  create      Create a new service
  inspect     Display detailed information on one or more services
  logs        Fetch the logs of a service or task
  ls          List services
  ps          List the tasks of one or more services
  rm          Remove one or more services
  rollback    Revert changes to a service's configuration
  scale       Scale one or multiple replicated services
  update      Update a service
```

### Create
Create a service:
```shell
$ docker service create --name www -p 8080:80 --replicas 3 nginx  # SHOULD BE LANCHED ON A MANAGER
$ docker service ls
$ docker service ps www # Exectued tasks
$ docker service scale www=1
$ docker service ps wwww
$ curl get 192.168.99.100
$ curl get 192.168.99.101
$ curl get 192.168.99.102
```

Example of a database:
```shell
$ docker service create                       \
    --mount type=volume,src=data,dst=/data/db \
    --name db                                 \
    --publish 27017:27017                     \
    mongo:4.0
$ docker service ls
$ docker volume ls
$ docker service rm
```

- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/service-creation.md

### Rolling upgrade
- By default update a replica and go to the next
```shell
$ docker service create    \
    --update-parallelism 2 \      # Replicas updated 2 by 2
    --update-delay 10s     \      # Wait 10s before update next replicas pool
    --replicas 4           \
    --publish 27017:27017  \
    --name vote            \
    instavote/vote

$ docker service update --image instavote/vote:indent vote
```

### Service rollback
```shell
$ docker service create    \
    --publish 27017:27017  \
    --name vote            \
    instavote/vote
$ docker service inspect vote     # .Spec

$ docker service update --image instavote/vote:indent vote
$ docker service inspect vote     # .Spec and .PreviousSpec

$ docker service rollback vote
```

- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/service-update-rollback.md


## Secret

- From v1.13
- Sensible data
- Commandline
- Stored in encrypted logs (Raft)
- And copied to the service, in (`cat`) `/run/secrets/SECRET_NAME`

```shell
$ echo "MyVaultPassword" | docker secret create password -
$ docker service create --name=api --secret=password lucj/api
$ docker service ps api
$ docker exec -ti $(docker ps --filter name=api -q) sh
/ cat /run/secrets/password
MyVaultPassword
$ docker service update --secret-rm="password" api
$ docker exec -ti $(docker ps --filter name=api -q) sh
/ cat /run/secrets/password
cat: /run/secrets/password: No such file or directory
```


## Config

- As a secret but not sensible
- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/config-et-secret.md 


## Stack

- A group of services
- As a complete application, compound with services
- Created / deployed with a [Docker Compose](./compose.md) file
```shell
$ docker stack --help

Commands:
  deploy      Deploy a new stack or update an existing stack
  ls          List stacks
  ps          List the tasks in the stack
  rm          Remove one or more stacks
  services    List the services in the stack
```

### Creation
```shell
$ git clone https://github.com/dockersamples/example-voting-app && cd example-voting-app
$ docker stack deploy -c docker-stack.yml vote
$ docker stack ls
NAME     SERVICES             ORCHESTRATOR
vote     6                    Swarm
$ docker stack ps
ID          NAME          IMAGE          NODE          DESIRED STATE          CURRENT STATE          ERROR
$ docker service ls
$ docker stack rm
```
- https://www.udemy.com/course/la-plateforme-docker/learn/lecture/13216024#overview
- https://github.com/dockersamples/example-voting-app/blob/master/docker-stack.yml

### Remove
```shell
$ docker stack rm vote
```


## TICK

- https://www.influxdata.com/time-series-platform/
- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/stack-TICK.md

> La stack TICK est principalement dédiée à la gestion des séries temporelles. 
> Elle constitue un choix intéressant en tant que backend de réception et de stockage de données
> provenant de capteurs IoT (par exemple: température, pression atmosphérique, niveau d'eau, ...).
> 
> Le nom de cette stack provient des éléments dont elle est composée:
> - Telegraf
> - InfluxDB
> - Chronograf
> - Kapacitor

![](https://gitlab.com/lucj/docker-exercices/-/raw/master/11.Swarm/images/tick-1.png)


## Routing Mesh
- Expose services from external, on all the nodes of the stack


## Backup & Restore
- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/restore.md


## Fault tolerance
- https://gitlab.com/lucj/docker-exercices/-/blob/master/11.Swarm/articles/tolerance-pannes.md


## Monitoring

### Command line
```shell
$ docker stack ps
ID          NAME          IMAGE          NODE          DESIRED STATE          CURRENT STATE          ERROR
```

### Visualizer
- See the `VISUALIZER` service [available in voting app](https://github.com/dockersamples/example-voting-app/blob/master/docker-stack.yml#L77):
- https://hub.docker.com/r/dockersamples/visualizer
- https://github.com/dockersamples/docker-swarm-visualizer

### Swarmprom: 
- https://github.com/stefanprodan/swarmprom
- `dockerd-exporter`: expose metrique du docker deamon
- `cadvisor`: expose metrics des conatianers du swarm
- [prometheus](https://github.com/stefanprodan/swarmprom/blob/master/docker-compose.yml#L149): collecte et sauve ces metrics
- `grafana`: affiche dans dashboards
- `alertmanager`: lance alertes sur ces metrics
- `unsee`: dashboard pour alertmanager
- `caddy`: expose points d'entrees de l'app

### Portainer.io
> Easily deploy, configure and secure containers in minutes on Docker, Kubernetes, Swarm and Nomad in any cloud, datacenter or device.
- https://www.portainer.io/
```shell
curl -L https://downloads.portainer.io/ee2-15/portainer-agent-stack.yml -o portainer-agent-stack.yml
```

### Swarmpit.io
> Operate your docker infrastructure like a champ
- https://swarmpit.io/
```shell
git clone https://github.com/swarmpit/swarmpit -b master
docker stack deploy -c swarmpit/docker-compose.yml swarmpit
```
Or with installer:
- https://github.com/swarmpit/installer
```shell
docker run -it --rm \
  --name swarmpit-installer \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  swarmpit/install:1.9
```


## Quiz

Which command to create a Swarm?
- `docker swarm init`

Which command to update replicas of a deployed service?
- `docker service update --replicas 8 myservice`
- `docker service scale myservice=8`

Which command to get token to add a node as manager?
- `docker swarm join-token manager`

What do this command `docker node update --availability drain node3`?
- Containers on this node will bw stopped and re-scheduled on other nodes

Does the availability of a node can be `paused`?
- No, it can be `pause`

Count of managers is recommended for a Swarm in production?
- 3
- Un Swarm comportant 3 managers tolère la panne d'un manager car le quorum de 2 sera présent pour les décisions de vote. Utiliser 4 managers ne changerait rien car le quorum de 3 tolèrerait également la panne d'un seul manager.

Dans le cadre d'un Swarm composé de 7 managers et réparti sur 3 datacenters, quelle est la répartition recommandée pour les managers ?
- 3-2-2

Get services status of a stack deployed with `docker stack deploy -c docker-stack.yml app`?
- [ ] `docker stack ls`
- [ ] `docker stack ls app`
- [x] `docker stack ps app`
- [ ] `docker services ls`

Command to get access to the secret `TOKEN` for the service `api`?
- `docker service update --secret-add TOKEN api`

`docker service update --update-delay 10s --update-parallelism 2 api`?
- Lors d'une mise à jour du service api, les replicas seront mis à jour 2 par 2, toutes les 10 secondes

Option to launch a service with a replica on each node?
- `--mode global`

Launch a service, with the image `nginx`, publish on port `80` from `8080` of each node, with 3 replicas?
- `docker service create --replicas=3 --publish 8080:80 nginx` (`-p` can replace `--publish`)

Where is the swarm state stored in a manager node?
- `/var/lib/docker/swarm`
