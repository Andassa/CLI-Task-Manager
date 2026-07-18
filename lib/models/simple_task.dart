import 'task.dart';

class SimpleTask extends Task {
  SimpleTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.status,
  });

  @override
  String get typeLabel => 'SIMPLE';
}
