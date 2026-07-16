import 'dart:io';

import 'exceptions/invalid_task_exception.dart';
import 'exceptions/task_not_found_exception.dart';
import 'models/simple_task.dart';
import 'models/task.dart';
import 'models/task_priority.dart';
import 'models/urgent_task.dart';
import 'repositories/json_task_repository.dart';
import 'services/task_service.dart';
import 'utils/console.dart';

Future<void> main(List<String> arguments) async {
  final storage = JsonTaskRepository('tasks.json');
  final service = TaskService(storage);
  final cli = TaskCli(service);
  await cli.run();
}

class TaskCli {
  final TaskService _service;

  TaskCli(this._service);

  Future<void> run() async {
    await _service.loadTasks();

    var running = true;
    while (running) {
      Console.clear();
      _printBanner();
      _printMenu();
      final choice = _ask('Votre choix').trim();
      print('');
      switch (choice) {
        case '1':
          await _addTask();
          _pause();
          break;
        case '2':
          _showTasks();
          _pause();
          break;
        case '3':
          await _completeTask();
          _pause();
          break;
        case '4':
          await _deleteTask();
          _pause();
          break;
        case '5':
          running = false;
          _info('A bientot.');
          break;
        default:
          _error('Choix invalide. Merci de saisir un nombre entre 1 et 5.');
          _pause();
      }
    }
  }

  void _printBanner() {
    print('');
    print('  ${Console.bold('Task Manager')}');
    print('  ${Console.gray('Gestionnaire de taches en ligne de commande')}');
  }

  void _printMenu() {
    final count = _service.getAllTasks().length;
    print('');
    print('  ${Console.gray('tache(s) enregistree(s): $count')}');
    print('  ${Console.gray('---------------------------------')}');
    print('  ${Console.cyan('1')}  Ajouter une tache');
    print('  ${Console.cyan('2')}  Voir les taches');
    print('  ${Console.cyan('3')}  Terminer une tache');
    print('  ${Console.cyan('4')}  Supprimer une tache');
    print('  ${Console.cyan('5')}  Quitter');
    print('');
  }

  Future<void> _addTask() async {
    final title = _ask('Titre');
    final urgentAnswer = _ask('Tache urgente ? (o/n)').trim().toLowerCase();
    final isUrgent = urgentAnswer == 'o' || urgentAnswer == 'oui';
    final deadline = _readDeadline();
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final Task task;
    if (isUrgent) {
      task = UrgentTask(id: id, title: title, deadline: deadline);
    } else {
      final priority = _readPriority();
      task = SimpleTask(
        id: id,
        title: title,
        priority: priority,
        deadline: deadline,
      );
    }

    try {
      await _service.addTask(task);
      _success('Tache ajoutee.');
    } on InvalidTaskException catch (error) {
      _error(error.message);
    }
  }

  void _showTasks() {
    final tasks = _service.getAllTasks();
    if (tasks.isEmpty) {
      _info('Aucune tache pour le moment.');
      return;
    }
    _printTasks(tasks);
  }

  Future<void> _completeTask() async {
    final task = _selectTask('terminer');
    if (task == null) {
      return;
    }
    try {
      final updated = await _service.completeTask(task.id);
      _success('Tache terminee: ${updated.title}');
    } on TaskNotFoundException catch (error) {
      _error(error.toString());
    }
  }

  Future<void> _deleteTask() async {
    final task = _selectTask('supprimer');
    if (task == null) {
      return;
    }
    try {
      final removed = await _service.deleteTask(task.id);
      _success('Tache supprimee: ${removed.title}');
    } on TaskNotFoundException catch (error) {
      _error(error.toString());
    }
  }

  /// Affiche la liste des taches et demande d'en choisir une par son numero.
  /// Retourne null si la liste est vide ou si le numero est invalide.
  Task? _selectTask(String action) {
    final tasks = _service.getAllTasks();
    if (tasks.isEmpty) {
      _info('Aucune tache pour le moment.');
      return null;
    }
    _printTasks(tasks);
    print('');
    final input = _ask('Numero de la tache a $action').trim();
    final index = int.tryParse(input);
    if (index == null || index < 1 || index > tasks.length) {
      _error('Numero invalide.');
      return null;
    }
    return tasks[index - 1];
  }

  void _printTasks(List<Task> tasks) {
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final number = Console.cyan('${i + 1}'.padLeft(2));
      final icon = task.isCompleted ? Console.green('[x]') : Console.dim('[ ]');
      final title = task.isCompleted ? Console.dim(task.title) : task.title;
      final badge = task is UrgentTask ? ' ${Console.red('URGENT')}' : '';
      final priority = _priorityLabel(task.priority);
      final deadline = task.deadline != null
          ? Console.gray('  echeance ${_formatDate(task.deadline!)}')
          : '';
      print('  $number  $icon  $title$badge  $priority$deadline');
    }
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Console.red('haute');
      case TaskPriority.medium:
        return Console.yellow('moyenne');
      case TaskPriority.low:
        return Console.gray('basse');
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  TaskPriority _readPriority() {
    while (true) {
      final input = _ask('Priorite (1=basse, 2=moyenne, 3=haute)').trim();
      switch (input) {
        case '1':
          return TaskPriority.low;
        case '2':
          return TaskPriority.medium;
        case '3':
          return TaskPriority.high;
        default:
          _error('Valeur invalide. Merci de saisir 1, 2 ou 3.');
      }
    }
  }

  DateTime? _readDeadline() {
    final input = _ask('Echeance (AAAA-MM-JJ, laisser vide si aucune)').trim();
    if (input.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(input);
    if (parsed == null) {
      _error('Date non reconnue, aucune echeance ne sera enregistree.');
      return null;
    }
    return parsed;
  }

  String _ask(String question) {
    stdout.write('  ${Console.cyan('>')} $question ');
    return stdin.readLineSync() ?? '';
  }

  void _pause() {
    print('');
    stdout.write('  ${Console.gray('Appuyez sur Entree pour continuer...')}');
    stdin.readLineSync();
  }

  void _success(String message) => print('  ${Console.green('[ok]')} $message');

  void _error(String message) => print('  ${Console.red('[x]')} $message');

  void _info(String message) => print('  ${Console.gray(message)}');
}
