import 'task.dart';
import 'task_priority.dart';

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.deadline,
    super.status,
  }) : super(priority: TaskPriority.high);

  @override
  String get typeLabel => 'URGENT';

  String buildAlert() {
    return 'Attention: la tache "$title" est urgente '
        'et doit etre traitee en priorite.';
  }
}
