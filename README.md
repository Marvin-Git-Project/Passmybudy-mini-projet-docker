# PayMyBuddy - Dockerized Application

## Description

Application Spring Boot permettant de gérer des transactions entre utilisateurs.
Ce projet est entièrement conteneurisé avec Docker :

- **Backend** : Spring Boot (Java 17)
- **Base de données** : MySQL 8
- **Registry Docker privé** + interface graphique (joxit)

---

## Prérequis

- Installer "Docker" ([https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/))
- Installer "Docker Compose"
- Installer "Git"

---

## Étape 1 — Cloner le repository

```bash
git clone https://github.com/Marvin-Git-Project/Passmybudy-mini-projet-docker.git
cd mini-projet-docker
```

---

## Étape 2 — Configurer les variables d'environnement

```bash
cp .env.example .env
```

Le fichier `.env` contient les variables suivantes (modifier SI NECESSAIRE) :

```env
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=db_paymybuddy
MYSQL_USER=user
MYSQL_PASSWORD=password
SPRING_DATASOURCE_URL=jdbc:mysql://paymybuddy-db:3306/db_paymybuddy
SPRING_DATASOURCE_USERNAME=user
SPRING_DATASOURCE_PASSWORD=password
```

---

## Étape 3 — Builder l'image Docker

Le projet utilise un **build multi-stage** :
- Étape 1 : compilation du projet avec Maven
- Étape 2 : exécution dans une image légère `amazoncorretto:17-alpine`

```bash
docker build -t paymybuddy-backend:latest .
```

Vérifier que l'image a bien été créée :

```bash
docker images
```

Résultat attendu :

```
REPOSITORY             TAG       IMAGE ID       CREATED         SIZE
paymybuddy-backend     latest    xxxxxxxxxxxx   X seconds ago   XXX MB
```

---

## Étape 4 — Tester l'image avec `docker run`

Avant de déployer, on teste que le conteneur démarre correctement :

```bash
docker run -d \
  -p 8080:8080 \
  --name test-backend \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/db_paymybuddy \
  -e SPRING_DATASOURCE_USERNAME=user \
  -e SPRING_DATASOURCE_PASSWORD=password \
  paymybuddy-backend:latest
```

Vérifier que le conteneur tourne :

```bash
docker ps -a
```

Consulter les logs :

```bash
docker logs test-backend
```

Stopper et supprimer le conteneur de test une fois vérifié :

```bash
docker stop test-backend
docker rm test-backend
```

---

## Étape 5 — Lancer le registry Docker privé

```bash
docker compose -f docker-compose-registry.yml up -d
```

Vérifier que le registry et l'interface graphique tournent :

```bash
docker ps
```

Résultat attendu :

```
CONTAINER ID   IMAGE                             PORTS                    NAMES
xxxxxxxxxxxx   registry:2                        0.0.0.0:5000->5000/tcp   registry
xxxxxxxxxxxx   joxit/docker-registry-ui:latest   0.0.0.0:8081->80/tcp     registry-ui
```

L'interface graphique est accessible depuis le navigateur :

```
http://localhost:8081
```

---

## Étape 6 — Pousser l'image sur le registry privé

Tagger l'image pour le registry local :

```bash
docker tag paymybuddy-backend:latest localhost:5000/paymybuddy-backend:latest
```

Pousser l'image :

```bash
docker push localhost:5000/paymybuddy-backend:latest
```

Résultat attendu :

```
The push refers to repository [localhost:5000/paymybuddy-backend]
xxxxxxxx: Pushed
latest: digest: sha256:xxxx size: xxxx
```

Vérifier que l'image est bien dans le registry :

```bash
curl http://localhost:5000/v2/_catalog
```

Résultat attendu :

```json
{"repositories":["mysql","paymybuddy-backend"]}
```

---

## Étape 7 — Déployer l'application complète

L'image du backend est maintenant récupérée depuis le registry privé (`localhost:5000`).

```bash
docker compose up -d
```

Vérifier que tous les conteneurs tournent :

```bash
docker ps
```

Résultat attendu :

```
CONTAINER ID   IMAGE                                      PORTS                    NAMES
xxxxxxxxxxxx   localhost:5000/paymybuddy-backend:latest   0.0.0.0:8080->8080/tcp   paymybuddy-backend
xxxxxxxxxxxx   mysql:8.0                                  0.0.0.0:3306->3306/tcp   paymybuddy-db
```

Accéder à l'application depuis le navigateur :

```
http://localhost:8080
```

---

## Configuration de la base de données

| Paramètre | Valeur |
|-----------|--------|
| Host | paymybuddy-db |
| Port | 3306 |
| Database | db_paymybuddy |
| Username | user |
| Password | password |


La base est initialisée automatiquement au premier démarrage grâce aux scripts SQL dans `initdb/`.

Vérifier les tables après démarrage :

```bash
docker exec -it paymybuddy-db mysql -uuser -ppassword db_paymybuddy
```

Ensuite, dans le shell MySQL :

```sql
SHOW TABLES;
```

---

## Commandes utiles

| Action | Commande |
|--------|----------|
| Voir les conteneurs actifs | `docker ps` |
| Logs du backend | `docker logs paymybuddy-backend` |
| Logs de la base de données | `docker logs paymybuddy-db` |
| Stopper l'application | `docker compose down` |
| Stopper le registry | `docker compose -f docker-compose-registry.yml down` |
| Reset complet (supprime les volumes) | `docker compose down -v` |

---

## Structure du projet

```
mini-projet-docker/
│
├── Dockerfile                        # Build multi-stage de l'application
├── docker-compose.yml                # Orchestration backend + base de données
├── docker-compose-registry.yml       # Registry Docker privé + UI
├── .env                              # Variables d'environnement (non versionné)
├── .env.example                      # Exemple de configuration
├── initdb/
│   └── create.sql                    # Script d'initialisation de la base
├── src/                              # Code source Spring Boot
├── target/
│   └── paymybuddy.jar                # JAR compilé
├── screenshots/
│   ├── app-login.png
│   ├── docker-up.png
│   ├── mysql-tables.png
│   └── registry.png
└── README.md
```

---

## Captures d'écran

### Conteneurs Docker en cours d'exécution
![Docker](./screenshots/docker-up.png)

### Interface de l'application (login)
![Login](./screenshots/app-login.png)

### Registry Docker privé (interface graphique)
![Registry](./screenshots/registry.png)

### Tables MySQL
![MySQL](./screenshots/mysql-tables.png)

---

## Auteur

Projet réalisé par **Marvin-Git-Project**  
Dans le cadre d'un bootcamp proposé par **Eazytraining**

