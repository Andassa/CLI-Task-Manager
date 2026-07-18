import 'dart:convert';
import 'dart:io';

import '../exceptions/invalid_task_exception.dart';
import '../interfaces/task_storage.dart';
import '../models/task.dart';
import '../utils/task_serializer.dart';

class JsonTaskRepository implements TaskStorage {
  final String filePath;

  JsonTaskRepository(this.filePath);

  @override
  Future<void> save(List<Task> tasks) async {
    final file = File(filePath);
    final data = tasks.map((task) => task.toJson()).toList();
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(data));
  }

  @override
  Future<List<Task>> load() async {
    final file = File(filePath);

    if (!await file.exists()) {
      return <Task>[];
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return <Task>[];
    }

    try {
      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((item) => TaskSerializer.fromJson(item as Map<String, dynamic>))
          .toList();
    } on InvalidTaskException {
      rethrow;
    } catch (error) {
      throw InvalidTaskException(
        'Le fichier "$filePath" contient des donnees invalides: $error',
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await load();
    tasks.removeWhere((task) => task.id == id);
    await save(tasks);
  }
}
