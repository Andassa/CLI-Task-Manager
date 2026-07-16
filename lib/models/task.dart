import 'task_priority.dart';
import 'task_status.dart';

/// Represente une tache.
///
/// Cette classe est abstraite: elle definit les proprietes et les
/// comportements communs a toutes les taches, mais elle ne peut pas etre
/// instanciee directement. Les types concrets (par exemple SimpleTask et
/// UrgentTask) heritent de cette classe et fournissent leur propre libelle.
abstract class Task {
  /// Identifiant unique de la tache. Il ne change plus apres la creation.
  final String id;

  /// Titre lisible de la tache.
  String title;

  /// Niveau de priorite de la tache.
  TaskPriority priority;

  /// Date d'echeance optionnelle. Peut rester nulle.
  DateTime? deadline;

  /// Etat courant de la tache (a faire ou terminee).
  TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.status = TaskStatus.pending,
  });

  /// Libelle court decrivant le type de tache.
  ///
  /// Chaque sous-classe doit fournir sa propre valeur. C'est ce membre
  /// abstrait qui oblige a creer des classes concretes.
  String get typeLabel;

  /// Indique si la tache est terminee.
  bool get isCompleted => status == TaskStatus.completed;

  /// Marque la tache comme terminee.
  void markCompleted() {
    status = TaskStatus.completed;
  }

  /// Marque la tache comme a faire.
  void markPending() {
    status = TaskStatus.pending;
  }

  @override
  String toString() {
    final deadlineText =
        deadline != null ? deadline!.toIso8601String() : 'aucune';
    return '[$typeLabel] $id | $title '
        '| priorite: ${priority.name} '
        '| statut: ${status.name} '
        '| echeance: $deadlineText';
  }
}
