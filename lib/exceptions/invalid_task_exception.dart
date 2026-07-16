/// Levee lorsqu'une tache est invalide (donnee manquante ou incoherente).
class InvalidTaskException implements Exception {
  final String message;

  InvalidTaskException(this.message);

  @override
  String toString() => 'InvalidTaskException: $message';
}
