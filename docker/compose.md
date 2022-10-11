# Docker Compose

- Gérer des applications complexes, ex: microservices
- Format de fichier `docker-compose.yml` et un binaire

Table of content
- [docker-compose.yml](#docker-composeyml)
- [The binary](#the-binary)
- [Service Discovery / DNS](#service-discovery--dns)
- [Voting App](#voting-app)

## docker-compose.yml
- https://docs.docker.com/compose/compose-file/
- Options:
    - Services
    - Volumes
    - Networks
    - Sercrets
    - Configs
- Instructions (pouvant être définies pour chaque service):
    - Images utilisées (obligatoire)
    - Nombre de replicas
    - Ports publiés (à l'exterieur)
    - Health check
    - Stratégie de redémarrage
    - Contraintes de déploiement (Swmarm)
    - Configuration de mises à jour (Swmarm)
    - Secrets utilisés (Swmarm)
    - Config utilisés (Swmarm)
- Motivation (différences à gérer entre DEV et PROD):
    - `bind-mount` du code applicatif (pas en PROD)
    - binding des ports
    - variables d'environnement
    - règles de redémarrage
    - services supplémentaires (tls, logs, monitoring...)
    - contraintes de placement
    - contraintes d'utilisation des ressources (RAM, CPU)

Un exemple avec app web, API et DB:
```yaml
version: '3.7' # FONCTION DU DEAMON UTILISE
volumes: 
	data:
networks:
	frontend:
	backend:
services:
	web:
		image: org/web:2.3
		networks:
			- frontend
		ports:
			- 80:80
	api:
		image: org/api:2.3
		networks:
			- backend
			- frontend
	db:
		image: mongo:4.0
		volumes:
			- data:/data/db
		networks:
			- backend
```

## The binary

- Indépendant du deamon
- Installation indépendante (mais incluse dans Docker Desktop)
    - https://docs.docker.com/compose/install/
- Commandes
    - `up` / `down`: creation / suppression d'une application
    - `start` / `stop`: démarrage/arrêt d'une application
    - `build`
    - `pull`
    - `logs`
    - `scale` `SERVICE=N`
    - `ps`
    - `--help`

## Service Discovery / DNS

Configuration:
```yaml
version: '3.7'
services:
	MYDB:
		image: mongo:4.0
```
Code (NodeJS):
```javascript
const url = 'mongodb://MYDB/todos';
```

## Voting App

- [Voting App](./voting-app.md)
