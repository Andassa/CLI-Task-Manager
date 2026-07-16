import '../models/task.dart';

/// Contrat de stockage des taches.
///
/// Dart ne possede pas de mot-cle "interface". On utilise donc une classe
/// abstraite dont les methodes n'ont pas de corps. Toute classe qui veut
/// jouer le role de stockage devra implementer ce contrat et fournir une
/// vraie logique pour chaque methode.
abstract class TaskStorage {
  /// Sauvegarde la liste complete des taches.
  Future<void> save(List<Task> tasks);

  /// Charge et retourne toutes les taches disponibles.
  Future<List<Task>> load();

  /// Supprime la tache qui correspond a l'identifiant donne.
  Future<void> delete(String id);
}
