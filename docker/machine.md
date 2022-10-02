# Docker Machine

> Docker Machine est un utilitaire permettant d'instancier des hôtes Docker (créer une machine virtuelle et d'y installer docker). 
> Il s'interface avec des hyperviseur locaux (Virtualbox, Hyper-V) et également avec de nombreux cloud providers 
> (DigitalOcean, Amazon EC2, Google Compute Engine, Microsoft Azure, ...)

- Créer un hote docker sur machine physique ou virtuelle (un docker daemon)
- https://gitlab.com/lucj/docker-exercices/-/blob/master/09.Machine/creation-local.md
- https://gitlab.com/lucj/docker-exercices/-/blob/master/09.Machine/creation-DigitalOcean.md

Install `docker-machine` on mac:
```shell
$ brew install docker-machine docker docker-compose
$ docker ps
$ docker-machine --help
$ docker-machine status node1
$ docker-machine ip node1
```

VirtualBox:
```shell
$ docker-machine create --driver virtualbox node1
$ docker-machine create --driver virtualbox \
--virtualbox-memory=2048 \
--virtualbox-disk-size=5000 \
node2
```

Digital Ocean:
```shell
$ docker-machine create --driver digitalocean \ 
--digitalocean-access-token=$TOKEN \
node1
$ docker-machine create --driver digitalocean \ 
--digitalocean-access-token=$TOKEN \
--digitalocean-region=lon1 \
--digitalocean-size=1gb \
node2
```

Amazon EC2:
```shell
$ docker-machine create --driver amazonec2 \ 
--amazonec2-access-key=${ACCESS_KEY_ID} \
--amazonec2-secret-key=${SECRET_ACCESS_KEY} \
node1
$ docker-machine create --driver digitalocean \ 
--amazonec2-access-key=${ACCESS_KEY_ID} \
--amazonec2-secret-key=${SECRET_ACCESS_KEY} \
--amazonec2-region=eu-west-1 \
--amazonec2-ami=ami-ed82e39e \
--amazonec2-instance-type=t2-large \
node2
```
