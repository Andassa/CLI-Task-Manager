import '../models/task.dart';

abstract class TaskStorage {
  Future<void> save(List<Task> tasks);

  Future<List<Task>> load();

  Future<void> delete(String id);
}
