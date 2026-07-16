import 'package:cli_task_manager/models/task_priority.dart';
import 'package:cli_task_manager/models/task_status.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:cli_task_manager/utils/task_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('TaskSerializer', () {
    test('fromJson reconstruit une tache urgente', () {
      final json = <String, dynamic>{
        'type': 'URGENT',
        'id': '10',
        'title': 'Reunion',
        'priority': 'high',
        'deadline': null,
        'status': 'pending',
      };

      final task = TaskSerializer.fromJson(json);

      expect(task, isA<UrgentTask>());
      expect(task.priority, TaskPriority.high);
    });

    test('fromJson lit une echeance et un statut termine', () {
      final json = <String, dynamic>{
        'type': 'SIMPLE',
        'id': '11',
        'title': 'Faire les courses',
        'priority': 'low',
        'deadline': '2026-07-20T00:00:00.000',
        'status': 'completed',
      };

      final task = TaskSerializer.fromJson(json);

      expect(task.status, TaskStatus.completed);
      expect(task.deadline, isNotNull);
      expect(task.deadline!.year, 2026);
    });
  });
}
