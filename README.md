# JobConnect 📱

Application mobile de recrutement permettant la mise en relation entre entreprises et candidats.

## 🎯 Fonctionnalités

### 👤 Rôle Employee (Candidat)

- ✅ Consulter la liste des offres d'emploi avec filtres (type de contrat, expérience, localisation, salaire)
- ✅ Consulter le détail d'une offre (description, compétences, salaire, localisation, informations entreprise)
- ✅ Postuler à une offre (upload de CV en PDF)
- ✅ Historique des candidatures avec statuts (Envoyée, En cours d'étude, Acceptée, Refusée)
- ✅ Gestion du profil (informations personnelles, parcours professionnel, compétences, CV, photo de profil)

### 🏢 Rôle Company (Entreprise)

- ✅ Publier une offre d'emploi (titre, description, compétences, salaire, type de contrat, localisation, date limite)
- ✅ Consulter la liste de ses offres publiées avec statistiques (nombre de candidats, date de création, statut)
- ✅ Consulter les candidats d'une offre
- ✅ Voir le profil détaillé du candidat (CV, compétences, expériences, informations de contact)
- ✅ Gestion du profil entreprise (logo, adresse, description, domaine, taille)

### 🔐 Fonctionnalités Transversales

- ✅ Authentification (Inscription/Connexion)
- ✅ Détection automatique du rôle (Company/Employee) après login
- ✅ Interface moderne et intuitive avec navigation par onglets
- ✅ Photo de profil / Logo entreprise

## 🚀 Installation

### Prérequis

- Flutter SDK (>=3.0.0)
- Dart SDK
- Un éditeur de code (VS Code, Android Studio, etc.)

### Étapes d'installation

1. Clonez le repository ou téléchargez le projet
2. Installez les dépendances :
   ```bash
   flutter pub get
   ```
3. Lancez l'application :
   ```bash
   flutter run
   ```

### Configuration des notifications push (Optionnel)

Pour activer les notifications push avec Firebase Cloud Messaging:
- Consultez [FIREBASE_SETUP.md](FIREBASE_SETUP.md) pour les étapes complètes
- Pour l'instant, les notifications locales sont fonctionnelles sans Firebase

## 📦 Dépendances principales

- `provider` : Gestion d'état
- `http` : Appels API (à configurer avec votre backend)
- `shared_preferences` : Stockage local
- `image_picker` : Sélection d'images
- `file_picker` : Sélection de fichiers (CV)
- `intl` : Formatage de dates
- `flutter_svg` : Support SVG

## 🏗️ Structure du projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── user_model.dart
│   ├── job_model.dart
│   └── application_model.dart
├── providers/                # Providers (gestion d'état)
│   └── auth_provider.dart
├── screens/                  # Écrans de l'application
│   ├── auth/                 # Authentification
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── employee/             # Écrans Candidat
│   │   ├── employee_home.dart
│   │   ├── job_list_screen.dart
│   │   ├── job_detail_screen.dart
│   │   ├── job_filters_sheet.dart
│   │   ├── apply_job_screen.dart
│   │   ├── application_history_screen.dart
│   │   └── employee_profile_screen.dart
│   └── company/               # Écrans Entreprise
│       ├── company_home.dart
│       ├── publish_job_screen.dart
│       ├── my_jobs_screen.dart
│       ├── job_candidates_screen.dart
│       ├── candidates_screen.dart
│       ├── candidate_detail_screen.dart
│       └── company_profile_screen.dart
├── services/                 # Services (API, etc.)
│   ├── job_service.dart
│   ├── notification_service.dart
│   ├── advanced_search_service.dart
│   └── api_service.dart
├── utils/                    # Utilitaires
│   └── app_theme.dart
└── localization/             # Ressources de traduction
    ├── en.json               # English
    ├── fr.json               # Français
    └── app_localizations.dart
```

## 🔌 Intégration Backend

L'application est maintenant intégrée avec le backend NestJS + MongoDB fourni.

### Lancer le backend

1. **Cloner le repository backend** (si pas déjà fait) :
   ```bash
   git clone https://github.com/MohamedFawziAbdellaoui/recruitment-app-backend.git
   cd recruitment-app-backend
   ```

2. **Lancer le backend avec Docker** :
   ```bash
   docker-compose up -d
   ```
   
   Le backend sera disponible sur : `http://localhost:3000`
   MongoDB sera lancé automatiquement sur le port `27017`

3. **Vérifier que le backend fonctionne** :
   - Ouvrez `http://localhost:3000` dans votre navigateur
   - Vous devriez voir une réponse du serveur

### Configuration

L'URL de base de l'API est configurée dans `lib/services/api_service.dart` :
```dart
static const String baseUrl = 'http://localhost:3000';
```

Pour changer l'URL (par exemple pour un appareil mobile), modifiez cette constante.

### Authentification

L'application utilise JWT pour l'authentification. Les tokens sont automatiquement :
- Sauvegardés après login/signup
- Inclus dans les headers de toutes les requêtes authentifiées
- Supprimés lors de la déconnexion

## 🎨 Personnalisation

Le thème de l'application peut être personnalisé dans `lib/utils/app_theme.dart`. Vous pouvez modifier :
- Les couleurs principales
- Les styles de texte
- Les formes des composants
- Etc.

## 🌍 Support multilingue

L'application supporte le **Français** (FR) et l'**Anglais** (EN) par défaut.

### Utiliser les traductions dans le code

```dart
import 'package:jobconnect/localization/app_localizations.dart';

// Utiliser la fonction tr() globale
Text(tr('jobs.title'))  // Affiche "Offres d'emploi" en FR, "Job offers" en EN

// Ou via le provider
Consumer<LocalizationProvider>(
  builder: (context, localizationProvider, _) {
    return Text(localizationProvider.appLocalizations.translate('jobs.title'));
  },
)
```

### Ajouter une nouvelle langue

1. Créer un fichier JSON dans `lib/localization/` (ex: `lib/localization/es.json`)
2. Copier la structure de traduction de `en.json` ou `fr.json`
3. Traduire tous les textes
4. Ajouter la locale dans `AppLocalizationsDelegate.supportedLocales`:
```dart
static const supportedLocales = [Locale('en'), Locale('fr'), Locale('es')];
```

5. Ajouter les traductions au dropdown du profil

### Structure des traductions

Les traductions sont organisées par domaine dans les fichiers JSON:
- `auth` : Authentification
- `navigation` : Navigation et menus
- `jobs` : Offres d'emploi
- `applications` : Candidatures
- `profile` : Profil utilisateur
- `settings` : Paramètres
- `messages` : Messages d'erreur/succès
- Etc.

## � Chat en temps réel

L'application inclut un système de messagerie permettant aux candidats de communiquer directement avec les entreprises.

### Fonctionnalités
- Conversations groupées par entreprise/candidat
- Historique des messages
- Compteur de messages non lus
- Horodatage des messages
- Support du timestamp formaté (1h, 2j, etc.)

### Utilisation
```dart
// Accéder au provider de chat
Consumer<ChatProvider>(
  builder: (context, chatProvider, _) {
    // Obtenir les conversations actuelles
    final conversations = chatProvider.conversations;
    
    // Envoyer un message
    chatProvider.sendMessage(conversationId, messageText);
    
    // Marquer comme lu
    chatProvider.markConversationAsRead(conversationId);
  },
)
```

### Intégration backend
Pour connecter le chat au backend WebSocket:
```dart
// À implémenter dans chat_provider.dart
final _webSocket = await WebSocket.connect('ws://localhost:3000/chat');
_webSocket.listen((message) {
  // Traiter les messages entrants
});
```

## 🎯 Recommandations d'offres personnalisées

L'application génère des recommandations intelligentes basées sur:

### Critères de recommandation
1. **Offres similaires aux favoris** (30 points)
2. **Produits similaires par localisation** (25 points)
3. **Type de contrat préféré** (15 points)
4. **Offres tendances** (15 points)
5. **Salaire attractif** (10 points)
6. **Postings récents** (5 points)

### Utilisation du service
```dart
import 'package:jobconnect/services/recommendation_service.dart';

// Obtenir des recommandations personnalisées
final recommendations = await RecommendationService.getRecommendations(
  favoriteJobIds: favoritesProvider.favoriteJobIds,
  appliedJobIds: [],
  userRole: 'employee',
  userLocation: 'Paris',
  maxResults: 5,
);

// Offres similaires
final similar = await RecommendationService.getSimilarJobs(jobId);

// Offres tendances
final trending = await RecommendationService.getTrendingJobs();

// Par plage salariale
final bySalary = await RecommendationService.getJobsBySalaryRange(
  minSalary: 40000,
  maxSalary: 60000,
);
```

### Intégration dans l'app
Les recommandations peuvent être affichées:
- En section "Offres pour vous" dans l'onglet Jobs
- En suggestions après une candidature
- En notifications quand une offre matching apparaît
- En section "Offres similaires" dans le détail d'une offre

## �📱 Test

Pour tester l'application :

1. **Assurez-vous que le backend est lancé** (voir section "Intégration Backend")
2. **Créez un compte Candidat** :
   - Sélectionnez "Candidat" lors de l'inscription
   - Le backend utilisera le type "employee"
3. **Créez un compte Entreprise** :
   - Sélectionnez "Entreprise" lors de l'inscription
   - Le backend utilisera le type "entreprise"



## � Améliorations Futures

- 🔄 Intégration d'un système de notation et commentaires
- 📊 Tableau de bord analytique pour les entreprises (statistiques des candidatures)
- 🤖 Intelligence artificielle pour les recommandations d'offres
- 💬 Chat en temps réel avec notifications instantanées
- 📱 Application mobile native (Android/iOS)
- 🌍 Géolocalisation avancée et recherche radar
- 📈 Système de matching candidat-offre basé sur l'IA
- 🎖️ Badges et certifications pour les candidats
- 🔗 Intégration LinkedIn/Indeed
- 💼 Portfolio et portfolio en ligne des candidats
- 📅 Calendrier d'entretiens avec synchronisation
- 🎥 Entretiens vidéo intégrés dans la plateforme

## �📄 Licence

Ce projet est un exemple d'application de recrutement développée avec Flutter.

## 👨‍💻 Développement

### Configuration de l'environnement

1. **Installez Flutter** :
   ```bash
   flutter --version  # Vérifiez que Flutter est installé
   ```

2. **Configurez votre IDE** :
   - VS Code : installez l'extension "Flutter"
   - Android Studio : installez le plugin Flutter

3. **Lancez le développement** :
   ```bash
   flutter run -d windows     # Sur Windows
   flutter run -d macos       # Sur macOS
   flutter run -d chrome      # Sur navigateur
   ```

4. **Hot Reload** :
   - Appuyez `r` pour hot reload (rechargement rapide)
   - Appuyez `R` pour hot restart

### Structure du code

- Suivez les conventions de nommage Dart
- Utilisez des providers pour la gestion d'état
- Organisez les services par domaines
- Commentez le code complexe

### Contribuer au projet

1. Fork le repository
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/ma-fonctionnalite`)
3. Committez vos changements (`git commit -m 'Ajoute ma fonctionnalité'`)
4. Poussez vers la branche (`git push origin feature/ma-fonctionnalite`)
5. Ouvrez une Pull Request

---

Développé avec ❤️ par  ALA CHAABOUNI  en Flutter


