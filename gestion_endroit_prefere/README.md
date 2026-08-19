
# Gestion d'endroits favoris

Application Flutter permettant à l'utilisateur d'ajouter des endroits qu'il aime, d'y associer une photo prise avec la caméra de son appareil, et d'enregistrer automatiquement sa localisation GPS affichée sur une carte Google Maps. Les endroits sont conservés localement grâce à une base de données SQLite, même après fermeture de l'application.

**Activité n°2 — Cours Développement Mobile, Niveau Approfondi**
Flutter avancé : Caméra, Riverpod v2 (NotifierProvider), Géolocalisation Google Maps

---

## Sommaire

- [Fonctionnalités](#fonctionnalités)
- [Technologies et packages utilisés](#technologies-et-packages-utilisés)
- [Architecture du projet](#architecture-du-projet)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration de la clé API Google Maps](#configuration-de-la-clé-api-google-maps)
- [Exécution de l&#39;application](#exécution-de-lapplication)
- [Guide de test](#guide-de-test)
- [Remarque sur l&#39;émulateur (localisation GPS)](#remarque-sur-lémulateur-localisation-gps)
- [Problèmes connus et pistes de résolution](#problèmes-connus-et-pistes-de-résolution)
- [Améliorations possibles](#améliorations-possibles)

---

## Fonctionnalités

- Ajout d'un endroit favori avec un **nom**, une **photo** prise via la caméra, et sa **localisation GPS**.
- Conversion automatique des coordonnées GPS en **adresse lisible** (geocoding inverse).
- Affichage de la liste des endroits favoris enregistrés.
- Consultation du détail d'un endroit : photo, nom, adresse, et carte Google Maps interactive.
- **Persistance locale** des données via SQLite : les endroits restent disponibles après fermeture de l'application.
- Gestion d'état centralisée avec **Riverpod v2** (`Notifier` / `NotifierProvider`).

## Technologies et packages utilisés

| Package                 | Rôle                                                                |
| ----------------------- | -------------------------------------------------------------------- |
| `flutter_riverpod`    | Gestion d'état global de l'application (syntaxe Riverpod v2)        |
| `image_picker`        | Accès à la caméra pour prendre une photo                          |
| `geolocator`          | Récupération des coordonnées GPS de l'appareil                    |
| `geocoding`           | Conversion des coordonnées GPS en adresse lisible                   |
| `google_maps_flutter` | Affichage des cartes Google Maps (mini-carte et carte détaillée)   |
| `uuid`                | Génération d'identifiants uniques pour chaque endroit              |
| `sqflite`             | Base de données locale SQLite pour la persistance des données      |
| `path`                | Construction du chemin du fichier de base de données sur l'appareil |

## Architecture du projet

```
lib/
 ├── modele/
 │    └── endroit.dart              # Modèle de données Endroit (+ toMap/fromMap)
 ├── services/
 │    └── database_service.dart     # Service SQLite (CRUD)
 ├── providers/
 │    └── endroits_provider.dart    # EndroitsNotifier + endroitsProvider (Riverpod v2)
 ├── widgets/
 │    ├── image_prise.dart          # Widget caméra
 │    ├── localisation_prise.dart   # Widget GPS + mini-carte
 │    └── endroits_list.dart        # Liste des endroits
 ├── vue/
 │    ├── ajout_endroit.dart        # Formulaire d'ajout
 │    ├── endroit_detail.dart       # Page de détails
 │    └── endroits_interface.dart   # Écran principal
 └── main.dart                      # Point d'entrée (ProviderScope)
```

**Flux de données** : `EndroitsInterface` (écran principal) écoute `endroitsProvider` via `ref.watch`. Chaque ajout ou suppression déclenche une écriture dans SQLite (`DatabaseService`) puis une mise à jour du `state` du `EndroitsNotifier`, ce qui reconstruit automatiquement l'interface.

## Prérequis

- Flutter SDK (canal stable, version récente recommandée)
- Un JDK 17 ou supérieur
- Android Studio (ou le SDK Android en ligne de commande) avec :
  - `compileSdk` 36
  - Un NDK installé (version indiquée dans `android/app/build.gradle`)
- Un compte Google Cloud avec facturation activée (nécessaire pour générer une clé API Google Maps)
- Un appareil Android physique ou un émulateur Android

## Installation

1. Cloner ou extraire le projet, puis se placer à sa racine :

   ```
   cd gestion_endroit_prefere
   ```
2. Installer les dépendances :

   ```
   flutter pub get
   ```

   Les packages suivants sont déjà déclarés dans `pubspec.yaml` (ajoutés via `flutter pub add`) :

   ```
   flutter pub add uuid
   flutter pub add flutter_riverpod
   flutter pub add image_picker
   flutter pub add google_maps_flutter
   flutter pub add geolocator
   flutter pub add geocoding
   flutter pub add sqflite
   flutter pub add path
   ```

## Configuration de la clé API Google Maps

L'application nécessite une clé API Google Maps valide pour afficher les cartes. **Sans cette clé, l'application plantera** dès qu'un widget `GoogleMap` tentera de s'afficher.

### 1. Générer une clé API

1. Se rendre sur [console.cloud.google.com](https://console.cloud.google.com)
2. Créer un nouveau projet (ou en sélectionner un existant)
3. Aller dans **APIs & Services → Library**, rechercher **Maps SDK for Android**, et cliquer sur **Activer**
4. Aller dans **APIs & Services → Credentials → + Create Credentials → API Key**
5. Copier la clé générée
6. *(Recommandé)* Restreindre la clé : **Restrictions d'application** → limiter à l'empreinte SHA-1 de l'appareil/émulateur utilisé, et **Restrictions d'API** → limiter à *Maps SDK for Android*

### 2. Renseigner la clé dans le projet

Cette clé n'est **jamais écrite en dur** dans le code source versionné. Elle est injectée à la compilation depuis `android/local.properties` (fichier non versionné, exclu du `.gitignore`).

Ouvrir (ou créer) `android/local.properties` et ajouter :

```properties
MAPS_API_KEY=votre_cle_api_ici
```

Cette valeur est automatiquement lue par `android/app/build.gradle` et injectée dans `AndroidManifest.xml` via un `manifestPlaceholder` (`${mapsApiKey}`).

> ⚠️ Si vous clonez ce projet depuis un dépôt Git, `local.properties` ne sera pas présent (il est ignoré volontairement) : vous devez recréer cette ligne vous-même avec votre propre clé.

### 3. Appliquer les changements

```
flutter clean
flutter run
```

## Exécution de l'application

1. Démarrer un émulateur Android (ou brancher un appareil physique avec le débogage USB activé)
2. Vérifier que l'appareil est bien détecté :
   ```
   flutter devices
   ```
3. Lancer l'application :
   ```
   flutter run
   ```

## Guide de test

Voici un parcours de test couvrant l'ensemble des fonctionnalités :

1. **Écran vide** : au premier lancement, l'écran principal affiche « Aucun endroit favori pour le moment. »
2. **Ajout d'un endroit** :
   - Appuyer sur le bouton **+** en haut à droite
   - Saisir un nom (ex. « Ma maison »)
   - Appuyer sur **Prendre une photo** et capturer une image avec la caméra
   - Appuyer sur **Obtenir ma localisation** et vérifier qu'une mini-carte avec l'adresse s'affiche après quelques secondes
   - Appuyer sur **Enregistrer l'endroit**
3. **Retour à la liste** : l'endroit ajouté apparaît en tête de la liste, avec sa vignette et son adresse
4. **Détail d'un endroit** : appuyer sur un élément de la liste pour ouvrir la page de détails (photo pleine largeur, nom, adresse, carte interactive)
5. **Persistance** : fermer complètement l'application (pas seulement la mettre en arrière-plan) puis la relancer — les endroits ajoutés doivent toujours être présents, preuve que la sauvegarde SQLite fonctionne
6. **Ajout sans photo ou sans nom** : tenter d'enregistrer sans renseigner le nom ou sans prendre de photo — un message d'erreur doit s'afficher et l'endroit ne doit pas être créé
7. **Ajout sans localisation** : ajouter un endroit sans appuyer sur « Obtenir ma localisation » — l'endroit doit être enregistré normalement, et sa page de détails ne doit pas afficher de carte

## Remarque sur l'émulateur (localisation GPS)

Sur un émulateur Android, la position GPS n'est pas réelle par défaut. Pour la simuler :

1. Ouvrir les **Extended Controls** de l'émulateur (icône `...` dans la barre d'outils)
2. Aller dans **Location**
3. Saisir une ville dans la barre de recherche
4. Cliquer sur **Set Location**

Sur un appareil physique, la position GPS réelle est utilisée automatiquement (l'autorisation de localisation sera demandée au premier usage).

## Problèmes connus et pistes de résolution

| Symptôme                                                                                              | Cause probable                                                                                                                      | Solution                                                                                                      |
| ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `Could not get unknown property 'flutter'` lors du build                                             | Version de Flutter trop ancienne, incompatible avec un plugin natif                                                                 | Mettre à jour Flutter (`flutter upgrade`)                                                                  |
| `Your project's Gradle version is lower than Flutter's minimum`                                      | Wrapper Gradle obsolète                                                                                                            | Mettre à jour`distributionUrl` dans `android/gradle/wrapper/gradle-wrapper.properties`                   |
| `Your project's Android Gradle Plugin version is lower than...`                                      | AGP obsolète                                                                                                                       | Mettre à jour la version dans le bloc`plugins` de `android/settings.gradle`                              |
| `Espace insuffisant sur le disque` pendant le build                                                  | Accumulation de caches Gradle de versions différentes                                                                              | Nettoyer`C:\Users\<utilisateur>\.gradle\caches` et `...\wrapper\dists`, ne garder que la version en cours |
| Erreur lors du téléchargement/décompression du NDK                                                  | Fichier verrouillé par l'antivirus ou processus Gradle bloqué                                                                     | `gradlew.bat --stop`, supprimer le dossier NDK incomplet, exclure le SDK Android de l'antivirus             |
| `requires a placeholder substitution but no value for <...>`                                         | Nom du`manifestPlaceholder` différent entre `AndroidManifest.xml` et `build.gradle`, ou clé absente de `local.properties` | Harmoniser le nom du placeholder (respecter la casse) et vérifier que`MAPS_API_KEY` est bien renseignée   |
| `unexpected element <uses-permission> found in <manifest><application>`                              | Balises`<uses-permission>` placées à l'intérieur de `<application>`                                                          | Déplacer les`<uses-permission>` au niveau racine de `<manifest>`, avant `<application>`                |
| `compileSdk` insuffisant pour une dépendance (`google_maps_flutter`, `package_info_plus`, etc.) | `compileSdk` du projet trop bas par rapport aux exigences des plugins                                                             | Mettre à jour`compileSdk` dans `android/app/build.gradle` (36 recommandé)                               |

## Améliorations possibles

- Ajouter la possibilité de **modifier** ou de **supprimer** un endroit existant depuis l'interface
- Permettre de choisir une photo depuis la **galerie** en plus de la caméra
- Ajouter une **recherche** ou un **tri** dans la liste des endroits
- Gérer plus finement les cas de **permission refusée définitivement** (redirection vers les paramètres de l'application)
- Ajouter des **tests unitaires** sur `EndroitsNotifier` et des **tests de widgets** sur les écrans principaux
