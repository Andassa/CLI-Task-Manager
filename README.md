# Dart CLI Task Manager

Une application en ligne de commande, ecrite en Dart pur, pour gerer une liste
de taches. Les taches sont sauvegardees automatiquement dans un fichier JSON
local, ce qui permet de les retrouver au prochain lancement.

Ce projet a ete pense comme un exemple clair d'architecture propre en Dart:
separation des responsabilites, programmation orientee objet, generiques,
interfaces et tests unitaires.

## Fonctionnalites

- Ajouter une tache (titre, priorite, echeance optionnelle).
- Marquer une tache comme terminee.
- Supprimer une tache.
- Lister les taches triees par priorite puis par echeance, avec leur statut.
- Deux types de taches: tache simple et tache urgente (toujours en priorite haute).
- Persistance automatique dans un fichier JSON.
- Interface en ligne de commande coloree et interactive.
- Gestion des erreurs avec des exceptions dediees.

## Architecture

Le code est organise par responsabilite:

```
lib/
  models/            Les donnees (Task, SimpleTask, UrgentTask) et les enums.
  interfaces/        Les contrats abstraits (TaskStorage).
  repositories/      La gestion des collections et la persistance JSON.
  services/          La logique metier (TaskService).
  exceptions/        Les exceptions personnalisees.
  utils/             Les outils (serialisation JSON, style console).
  main.dart          Le point d'entree et l'interface CLI.

test/                Les tests unitaires.
```

Roles principaux:

- `Task` est une classe abstraite. `SimpleTask` et `UrgentTask` en heritent.
  `UrgentTask` a un comportement specifique: elle est toujours en priorite haute.
- `TaskStorage` est une interface (classe abstraite) qui definit les operations
  de stockage: `save`, `load`, `delete`.
- `Repository<T>` est un repository generique. `InMemoryRepository<T>` en est
  une implementation reutilisable, et `TaskRepository` la specialise pour les taches.
- `JsonTaskRepository` implemente `TaskStorage` et gere la lecture et l'ecriture
  du fichier JSON, y compris le cas du fichier inexistant.
- `TaskService` contient la logique metier et fait le lien entre la memoire et
  le stockage. Il sauvegarde automatiquement apres chaque modification.

## Technologies utilisees

- Dart
- Package `test` pour les tests unitaires.
- Package `lints` pour les regles d'analyse statique.

## Installation

Cloner le projet puis recuperer les dependances:

```bash
dart pub get
```

## Lancer l'application

Depuis la racine du projet:

```bash
dart run
```

Il est aussi possible de lancer directement le fichier principal:

```bash
dart run lib/main.dart
```

Les taches sont affichees triees par priorite (la plus haute d'abord), puis par
echeance. Le fichier `tasks.json` est cree automatiquement dans le dossier
courant au premier ajout de tache.

## Lancer les tests

Tous les tests:

```bash
dart test
```

Un seul fichier de test:

```bash
dart test test/task_service_test.dart
```

Sortie detaillee:

```bash
dart test -r expanded
```

## Exemple d'utilisation

Au lancement, un menu s'affiche:

```
  Task Manager
  Gestionnaire de taches en ligne de commande

  tache(s) enregistree(s): 0
  ---------------------------------
  1  Ajouter une tache
  2  Voir les taches
  3  Terminer une tache
  4  Supprimer une tache
  5  Quitter

  > Votre choix 1
```

Apres avoir ajoute quelques taches, l'option "Voir les taches" affiche:

```
   1  [x]  Preparer la reunion URGENT  haute  echeance 2026-07-20
   2  [ ]  Acheter du cafe  moyenne
```

La case `[x]` indique une tache terminee, `[ ]` une tache a faire. Pour terminer
ou supprimer une tache, il suffit de choisir son numero dans la liste.

Les donnees sont stockees dans `tasks.json`, par exemple:

```json
[
  {
    "type": "URGENT",
    "id": "1784239708481165",
    "title": "Preparer la reunion",
    "priority": "high",
    "deadline": "2026-07-20T00:00:00.000",
    "status": "completed"
  }
]
```
