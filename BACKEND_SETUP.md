# Configuration du Backend

## Prérequis

- Docker Desktop installé et lancé
- Git

## Étapes d'installation

1. **Cloner le repository backend** :
   ```bash
   git clone https://github.com/MohamedFawziAbdellaoui/recruitment-app-backend.git
   cd recruitment-app-backend
   ```

2. **Créer un fichier .env** (si nécessaire) :
   Le backend peut nécessiter un fichier `.env` avec les variables d'environnement MongoDB.
   Créez un fichier `.env` à la racine du projet backend avec :
   ```
   MONGO_ROOT_USERNAME=admin
   MONGO_ROOT_PASSWORD=password
   ```

3. **Lancer le backend avec Docker** :
   ```bash
   docker-compose up -d
   ```

4. **Vérifier que les conteneurs sont lancés** :
   ```bash
   docker ps
   ```
   
   Vous devriez voir deux conteneurs :
   - `nestjs_api` (port 3000)
   - `mongo_db` (port 27017)

5. **Vérifier les logs** (optionnel) :
   ```bash
   docker-compose logs -f
   ```

## Arrêter le backend

```bash
docker-compose down
```

## Redémarrer le backend

```bash
docker-compose restart
```

## Accès

- **API Backend** : http://localhost:3000
- **MongoDB** : localhost:27017

## Endpoints principaux

- `POST /auth/login` - Connexion
- `POST /auth/signup` - Inscription
- `GET /job` - Liste des offres
- `POST /job/create` - Créer une offre
- `GET /applications` - Liste des candidatures
- `POST /applications` - Postuler à une offre

Tous les endpoints (sauf login/signup) nécessitent un token JWT dans le header `Authorization: Bearer <token>`.

