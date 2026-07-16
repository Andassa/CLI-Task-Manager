import '../models/simple_task.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/task_status.dart';
import '../models/urgent_task.dart';

class TaskSerializer {
  static Task fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final id = json['id'] as String;
    final title = json['title'] as String;
    final priority = TaskPriority.values.byName(json['priority'] as String);
    final status = TaskStatus.values.byName(json['status'] as String);

    final deadlineRaw = json['deadline'] as String?;
    final deadline = deadlineRaw != null ? DateTime.parse(deadlineRaw) : null;

    switch (type) {
      case 'URGENT':
        return UrgentTask(
          id: id,
          title: title,
          deadline: deadline,
          status: status,
        );
      default:
        return SimpleTask(
          id: id,
          title: title,
          priority: priority,
          deadline: deadline,
          status: status,
        );
    }
  }
}
