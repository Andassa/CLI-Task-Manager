import '../models/task.dart';
import 'in_memory_repository.dart';

class TaskRepository extends InMemoryRepository<Task> {

  Task? findById(String id) {
    for (final task in getAll()) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }
}
