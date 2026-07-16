import '../exceptions/invalid_task_exception.dart';
import '../exceptions/task_not_found_exception.dart';
import '../interfaces/task_storage.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';


class TaskService {
  final TaskRepository _repository;
  final TaskStorage _storage;

  TaskService(this._storage, {TaskRepository? repository})
      : _repository = repository ?? TaskRepository();


  Future<void> loadTasks() async {
    final tasks = await _storage.load();
    _repository.replaceAll(tasks);
  }
  List<Task> getAllTasks() => _repository.getAll();

  Future<void> addTask(Task task) async {
    if (task.title.trim().isEmpty) {
      throw InvalidTaskException('Le titre de la tache ne peut pas etre vide.');
    }
    if (_repository.findById(task.id) != null) {
      throw InvalidTaskException(
        'Une tache avec l\'identifiant "${task.id}" existe deja.',
      );
    }
    _repository.add(task);
    await _persist();
  }
  Future<Task> completeTask(String id) async {
    final task = _requireTask(id);
    task.markCompleted();
    await _persist();
    return task;
  }

  Future<Task> deleteTask(String id) async {
    final task = _requireTask(id);
    _repository.remove(task);
    await _persist();
    return task;
  }

  Task _requireTask(String id) {
    final task = _repository.findById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    return task;
  }

  Future<void> _persist() async {
    await _storage.save(_repository.getAll());
  }
}
