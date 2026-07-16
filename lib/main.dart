import 'dart:io';

import 'exceptions/invalid_task_exception.dart';
import 'exceptions/task_not_found_exception.dart';
import 'models/simple_task.dart';
import 'models/task.dart';
import 'models/task_priority.dart';
import 'models/urgent_task.dart';
import 'repositories/json_task_repository.dart';
import 'services/task_service.dart';

/// Point d'entree de l'application.
///
/// On cree le stockage JSON, on le donne au service metier, puis on lance
/// l'interface en ligne de commande.
Future<void> main(List<String> arguments) async {
  final storage = JsonTaskRepository('tasks.json');
  final service = TaskService(storage);
  final cli = TaskCli(service);
  await cli.run();
}

/// Interface en ligne de commande.
///
/// Cette classe s'occupe uniquement de l'affichage et de la saisie.
/// Toute la logique metier reste dans le TaskService.
class TaskCli {
  final TaskService _service;

  TaskCli(this._service);

  Future<void> run() async {
    await _service.loadTasks();

    var running = true;
    while (running) {
      _printMenu();
      final choice = _readLine('Votre choix: ');
      switch (choice.trim()) {
        case '1':
          await _addTask();
          break;
        case '2':
          _showTasks();
          break;
        case '3':
          await _completeTask();
          break;
        case '4':
          await _deleteTask();
          break;
        case '5':
          running = false;
          print('Au revoir.');
          break;
        default:
          print('Choix invalide. Merci de saisir un nombre entre 1 et 5.');
      }
    }
  }

  void _printMenu() {
    print('');
    print('=========================');
    print('Task Manager');
    print('=========================');
    print('');
    print('1. Ajouter une tache');
    print('2. Voir les taches');
    print('3. Terminer une tache');
    print('4. Supprimer une tache');
    print('5. Quitter');
    print('');
  }

  Future<void> _addTask() async {
    final title = _readLine('Titre: ');
    final urgentAnswer = _readLine('Tache urgente ? (o/n): ').trim().toLowerCase();
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
      print('Tache ajoutee avec l\'identifiant $id.');
    } on InvalidTaskException catch (error) {
      print('Erreur: ${error.message}');
    }
  }

  void _showTasks() {
    final tasks = _service.getAllTasks();
    if (tasks.isEmpty) {
      print('Aucune tache pour le moment.');
      return;
    }
    print('Liste des taches:');
    for (final task in tasks) {
      print('- $task');
    }
  }

  Future<void> _completeTask() async {
    final id = _readLine('Identifiant de la tache a terminer: ').trim();
    try {
      final task = await _service.completeTask(id);
      print('Tache terminee: ${task.title}');
    } on TaskNotFoundException catch (error) {
      print('Erreur: $error');
    }
  }

  Future<void> _deleteTask() async {
    final id = _readLine('Identifiant de la tache a supprimer: ').trim();
    try {
      final task = await _service.deleteTask(id);
      print('Tache supprimee: ${task.title}');
    } on TaskNotFoundException catch (error) {
      print('Erreur: $error');
    }
  }

  TaskPriority _readPriority() {
    while (true) {
      final input = _readLine('Priorite (1=low, 2=medium, 3=high): ').trim();
      switch (input) {
        case '1':
          return TaskPriority.low;
        case '2':
          return TaskPriority.medium;
        case '3':
          return TaskPriority.high;
        default:
          print('Valeur invalide. Merci de saisir 1, 2 ou 3.');
      }
    }
  }

  DateTime? _readDeadline() {
    final input = _readLine(
      'Echeance (format AAAA-MM-JJ, laisser vide si aucune): ',
    ).trim();
    if (input.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(input);
    if (parsed == null) {
      print('Date non reconnue, aucune echeance ne sera enregistree.');
      return null;
    }
    return parsed;
  }

  String _readLine(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync() ?? '';
  }
}
