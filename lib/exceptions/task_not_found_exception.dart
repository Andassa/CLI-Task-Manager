/// Levee lorsqu'aucune tache ne correspond a l'identifiant recherche.
class TaskNotFoundException implements Exception {
  final String id;

  TaskNotFoundException(this.id);

  @override
  String toString() {
    return 'TaskNotFoundException: aucune tache trouvee '
        'avec l\'identifiant "$id".';
  }
}
