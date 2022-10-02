# Docker Swarm

> The clustering and orchestration solution from Docker
> - to manage a hosts cluster
> - orchestrate the services of this cluster

![](https://gitlab.com/lucj/docker-exercices/-/raw/master/11.Swarm/images/swarm1.png)

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

## Commands

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

## Node

- Machine included in the Swarm
- Can be
  - `Manager`
    - Schedule and orchestrate containers, if Leader
    - Manage the cluster state
    - RAFT
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

Create virtual machines (future nodes):
````shell
$ docker-machine create --driver virtualbox node1
$ docker-machine create --driver virtualbox node2
$ docker-machine create --driver virtualbox node3

# $ docker-machine regenerate-certs node3 
# $ docker-machine restart node3
````

Initialize the Swarm (connected onto the node1):
````shell
$ docker-machine ssh node1
@node1$ docker swarm init
@node1$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
hxe06csr1ffvedr6hqcsyypau *   node1               Ready               Active              Leader              19.03.12
````

Attach other nodes as workers (connected onto them):
````shell
$ docker-machine ssh node2
@node2$ docker swarm join --token SWMTKN-1-56t0awp55yflnr7oka9l7d7z7swhbervijmzze55b3wn4n2chy-93ddiva70ww50fmsoavrw1yom 192.168.99.104:2377

$ docker-machine ssh node3
@node3$ docker swarm join --token SWMTKN-1-56t0awp55yflnr7oka9l7d7z7swhbervijmzze55b3wn4n2chy-93ddiva70ww50fmsoavrw1yom 192.168.99.104:2377
@node1$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
hxe06csr1ffvedr6hqcsyypau *   node1               Ready               Active              Leader              19.03.12
````

Check system (from manager node1):
````shell
@node1$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS      ENGINE VERSION
d0ygaohomid6b9mttlr8i4b6r *   node1               Ready               Active              Leader              19.03.12
0myxlr2lbmnr4fl8d9curhjhh     node2               Ready               Active                                  19.03.12
xym9kgs3yp9bnnd3zf3sc3hxs     node3               Ready               Active                                  19.03.12
````

Promote workers (from manager node1):
````shell
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
````
