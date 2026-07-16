import 'package:cli_task_manager/models/simple_task.dart';
import 'package:cli_task_manager/models/task_priority.dart';
import 'package:cli_task_manager/models/task_status.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('Task', () {
    test('creation d\'une tache simple', () {
      final task = SimpleTask(
        id: '1',
        title: 'Test',
        priority: TaskPriority.low,
      );

      expect(task.id, '1');
      expect(task.title, 'Test');
      expect(task.priority, TaskPriority.low);
      expect(task.status, TaskStatus.pending);
      expect(task.isCompleted, isFalse);
    });

    test('changement du statut vers termine', () {
      final task = SimpleTask(
        id: '1',
        title: 'Test',
        priority: TaskPriority.low,
      );

      task.markCompleted();

      expect(task.status, TaskStatus.completed);
      expect(task.isCompleted, isTrue);
    });

    test('une tache urgente est toujours de priorite haute', () {
      final task = UrgentTask(id: '2', title: 'Urgent');

      expect(task.priority, TaskPriority.high);
      expect(task.typeLabel, 'URGENT');
    });

    test('conversion vers JSON contient les champs attendus', () {
      final task = SimpleTask(
        id: '3',
        title: 'Json',
        priority: TaskPriority.medium,
      );

      final json = task.toJson();

      expect(json['type'], 'SIMPLE');
      expect(json['id'], '3');
      expect(json['title'], 'Json');
      expect(json['priority'], 'medium');
      expect(json['status'], 'pending');
      expect(json['deadline'], isNull);
    });
  });
}
