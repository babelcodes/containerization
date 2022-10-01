# Docker

## Theory

### Presentation
- Platform to build, distribute and deploy applications in conainers
- Language agnostic
- With orchestration
- Ensure scalability
- Accelerate the setup of automatics deployment pipelines and the releases frequency

### Architecture
- A client: `docker`
- That communicates with a daemon: `dockerd`
  - Hosted on a **Docker Host**
- Via REST API
  - https://docs.docker.com/engine/api/latest/
- Binaries developed in GO
- The daemon communicates with a registry
- A Docker Host contains
  - A single `docked` daemon
  - Some images
  - Some containers
  - Can be regrouped in a cluster **Swarm**

### Concepts
- Docker facilitate the usage of Linux **containers**
- A container is launched from an **image**
- An image contains an application and its dependencies
- The file `Dockerfile` is used for the creation of an image
- An image is distributed via a **Registry**
- Launch containers on a single host or several grouped as **Swarm**

### Container
- Namespace: Linux technology to isolate processes and limit what a container can see
- Control Groups: to limit resources
- A container can be viewed as a process, isolate from the others


## Images

### REPL

Launch a docker image as a CLI:

```shell
docker container run -ti python:3
docker container run -ti ruby:2.5.1
docker container run -ti node:8.12-alpine  # alpine linux, small and securized
```

Run an image:

```shell
docker container run -p 27017:27017 mongo:4.0
docker container run -p 80:3000 redmine:3
```


## Ecosystem

### play-with-docker.com

- https://labs.play-with-docker.com/

```shell
> Start
> Add new instance
docker version
docker container run -p 80:3000 redmine:3
```


### Vagrant

See `../vagrant`
