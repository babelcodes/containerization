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
- Template de container
- System de fichiers avec dépendances
- Composés de couches / layers! Partagées entre images
- Élément portable à condition que le runtime soit présent
- Distribuée via registry , ex: DockerHub (hub.docker.com)
- Constituée de:
	- Code
	- Librairies
	- Environnement d’exécution
- `Dockerfile` commands:
   - https://www.udemy.com/course/la-plateforme-docker/learn/lecture/13216276#overview
- Commands `docker image <command>`:
	- `pull`, user/image:version
	- `push` (login)
	- `inspect`
	- `history`, les layers utilisées pour créer une image
	- `ls`
		- `--filter dangling=true` (les images qui ne sont plus référencées (sans nom ni version) et qui peuvent être supprimées
		- `-q` = la liste des ID
		- `prune` pour supprimer tous les dangling
	- `save` / `load`
	- `rm`
		- `docker image rm ${docker image ls -q}`

`vi Dockerfile`

```
FROM node:10.13.0-alpine
COPY . /app/
RUN cd /app && npm i
EXPOSE 8080
WORKDIR /app
CMD ["npm", "start]
```

`docker image build -t app:0.1 .`

`docker container run -p 8080:8080 app:0.1`

- Multi-stages build
	- since:17.5
	- https://gitlab.com/lucj/docker-exercices/-/blob/master/06.Images/multi-stage-build-GO.md 
- Cache
   - Mettre le plus bas dans le `Dockerfile` les éléments qui sont modifiés le plus souvent
   - https://gitlab.com/lucj/docker-exercices/-/blob/master/06.Images/cache.md 
- Build Context
	- `.dockerignore` (.git, node_module...)

## Registry

- Pour deployer
- Build *Ship* Run
- push / pull

Providers
- hub.docker.com
	- Docker Registry
	- Docker Trusted Registry
- Amazon EC2 container registry
- Google Container Registry
- GitLab container registry

Docker Hub
- Intégration avec Github et BitBucket
- Mais aussi des plugins
- Images officielles et celles certifiées
- ou encore les publiques (attention)
- Repository public ou privé
	- Tag: user/iamge:version
- Intégration: pousser dans une branche puis un webhook deploy sur docker hub

```
subl Dockerfile
docker image ls
docker image build -t jacquescouvreur/www:1.0 .
## OR TAG EXISTING IMAGE: docker image tag IMAGE USERNAME/www:1.0
docker image ls
docker login
docker image push jacquescouvreur/www:1.0
docker image rm jacquescouvreur/www:1.0
docker image ls
docker image pull jacquescouvreur/www:1.0
```

Docker Open Source Registry
- https://docs.docker.com/registry/configuration/
- 	https://www.udemy.com/course/la-plateforme-docker/learn/lecture/13216234#overview
- peut deployer en local, sinon securiser
- https://gitlab.com/lucj/docker-exercices/-/blob/master/07.Registry/setup-open-source-registry.md
- https://gitlab.com/lucj/docker-exercices/-/blob/master/07.Registry/configure-open-source-registry.md
```
docker container run --name registry -d -p 5000:5000 registry:2.6.2
curl localhost:5000/v2/_catalog
docker image pull nginx:1.14-alpine
docker image tag nginx:1.14-alpine localhost:5000/nginx:1.14
docker image push localhost:5000/nginx:1.14
curl localhost:5000/v2/_catalog
docker container rm -f registry
```


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
