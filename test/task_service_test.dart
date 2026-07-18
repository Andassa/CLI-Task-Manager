import 'dart:io';

import 'package:cli_task_manager/exceptions/invalid_task_exception.dart';
import 'package:cli_task_manager/exceptions/task_not_found_exception.dart';
import 'package:cli_task_manager/models/simple_task.dart';
import 'package:cli_task_manager/models/task_priority.dart';
import 'package:cli_task_manager/repositories/json_task_repository.dart';
import 'package:cli_task_manager/services/task_service.dart';
import 'package:test/test.dart';

void main() {
  group('TaskService', () {
    late Directory tempDir;
    late TaskService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('task_service_test');
      final storage = JsonTaskRepository('${tempDir.path}/tasks.json');
      service = TaskService(storage);
      await service.loadTasks();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('addTask ajoute une tache', () async {
      await service.addTask(
        SimpleTask(id: '1', title: 'Test', priority: TaskPriority.low),
      );

      expect(service.getAllTasks(), hasLength(1));
    });

    test('completeTask marque la tache comme terminee', () async {
      await service.addTask(
        SimpleTask(id: '1', title: 'Test', priority: TaskPriority.low),
      );

      final task = await service.completeTask('1');

      expect(task.isCompleted, isTrue);
    });

    test('deleteTask supprime la tache', () async {
      await service.addTask(
        SimpleTask(id: '1', title: 'Test', priority: TaskPriority.low),
      );

      await service.deleteTask('1');

      expect(service.getAllTasks(), isEmpty);
    });

    test('deleteTask leve TaskNotFoundException si id inconnu', () async {
      expect(
        () => service.deleteTask('inconnu'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('addTask leve InvalidTaskException si le titre est vide', () async {
      expect(
        () => service.addTask(
          SimpleTask(id: '1', title: '   ', priority: TaskPriority.low),
        ),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('getAllTasks trie les taches par priorite decroissante', () async {
      await service.addTask(
        SimpleTask(id: '1', title: 'Basse', priority: TaskPriority.low),
      );
      await service.addTask(
        SimpleTask(id: '2', title: 'Haute', priority: TaskPriority.high),
      );
      await service.addTask(
        SimpleTask(id: '3', title: 'Moyenne', priority: TaskPriority.medium),
      );

      final tasks = service.getAllTasks();

      expect(tasks[0].priority, TaskPriority.high);
      expect(tasks[1].priority, TaskPriority.medium);
      expect(tasks[2].priority, TaskPriority.low);
    });
  });
}
