import 'task_priority.dart';
import 'task_status.dart';

abstract class Task {

  final String id;

  String title;

  TaskPriority priority;

  DateTime? deadline;

  TaskStatus status;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.status = TaskStatus.pending,
  });

  String get typeLabel;

  bool get isCompleted => status == TaskStatus.completed;

  void markCompleted() {
    status = TaskStatus.completed;
  }

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
