import 'dart:io';

import 'package:cli_task_manager/exceptions/invalid_task_exception.dart';
import 'package:cli_task_manager/models/simple_task.dart';
import 'package:cli_task_manager/models/task_priority.dart';
import 'package:cli_task_manager/models/task_status.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:cli_task_manager/repositories/json_task_repository.dart';
import 'package:test/test.dart';

void main() {
  group('JsonTaskRepository', () {
    late Directory tempDir;
    late String filePath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('task_manager_test');
      filePath = '${tempDir.path}/tasks.json';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('load retourne une liste vide si le fichier n\'existe pas', () async {
      final repository = JsonTaskRepository(filePath);

      final tasks = await repository.load();

      expect(tasks, isEmpty);
    });

    test('save puis load conserve les taches', () async {
      final repository = JsonTaskRepository(filePath);
      final task = SimpleTask(
        id: '1',
        title: 'Test',
        priority: TaskPriority.high,
      );

      await repository.save([task]);
      expect(File(filePath).existsSync(), isTrue);

      final loaded = await repository.load();
      expect(loaded, hasLength(1));
      expect(loaded.first.id, '1');
      expect(loaded.first.title, 'Test');
      expect(loaded.first.priority, TaskPriority.high);
    });

    test('load retourne une liste vide si le fichier est vide', () async {
      await File(filePath).writeAsString('   ');

      final repository = JsonTaskRepository(filePath);

      final tasks = await repository.load();

      expect(tasks, isEmpty);
    });

    test(
      'save puis load conserve le type et l\'echeance d\'une tache urgente',
      () async {
        final repository = JsonTaskRepository(filePath);
        final deadline = DateTime(2026, 7, 20);

        await repository.save([
          UrgentTask(
            id: '9',
            title: 'Livrer le projet',
            deadline: deadline,
            status: TaskStatus.completed,
          ),
        ]);

        final loaded = await repository.load();

        expect(loaded, hasLength(1));
        expect(loaded.first, isA<UrgentTask>());
        expect(loaded.first.priority, TaskPriority.high);
        expect(loaded.first.status, TaskStatus.completed);
        expect(loaded.first.deadline, deadline);
      },
    );

    test('load leve InvalidTaskException si le fichier est corrompu', () async {
      await File(filePath).writeAsString('ceci n\'est pas du json valide');

      final repository = JsonTaskRepository(filePath);

      expect(() => repository.load(), throwsA(isA<InvalidTaskException>()));
    });

    test('delete retire la tache du fichier', () async {
      final repository = JsonTaskRepository(filePath);
      await repository.save([
        SimpleTask(id: '1', title: 'A', priority: TaskPriority.low),
        SimpleTask(id: '2', title: 'B', priority: TaskPriority.low),
      ]);

      await repository.delete('1');

      final loaded = await repository.load();
      expect(loaded, hasLength(1));
      expect(loaded.first.id, '2');
    });
  });
}
