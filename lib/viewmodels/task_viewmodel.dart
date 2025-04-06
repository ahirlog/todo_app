import 'package:flutter/material.dart';
import 'dart:async';

import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/firebase_service.dart';

class TaskViewModel extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _taskSubscription;

  int _limit = 20;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  TaskViewModel() {
    _initTaskStream();
  }

  void _initTaskStream() {
    _isLoading = true;
    notifyListeners();

    _taskSubscription = FirebaseService.getTasks().listen((taskList) {
      _tasks = taskList;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error getting tasks: $error");
    });
  }

  Future<void> addTask(String title, String description) async {
    try {
      final newTask = Task(
        id: '',
        title: title,
        description: description,
        createdAt: DateTime.now(),
        ownerId: FirebaseService.currentUserId,
      );

      await FirebaseService.addTask(newTask);
    } catch (e) {
      debugPrint("Error adding task: $e");
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await FirebaseService.updateTask(task);
    } catch (e) {
      debugPrint("Error updating task: $e");
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await FirebaseService.deleteTask(id);
    } catch (e) {
      debugPrint("Error deleting task: $e");
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    } catch (e) {
      debugPrint("Error toggling task completion: $e");
      rethrow;
    }
  }

  Future<void> shareTask(String taskId, String email) async {
    try {
      await FirebaseService.shareTask(taskId, email);
    } catch (e) {
      debugPrint("Error sharing task: $e");
      rethrow;
    }
  }

  void loadMoreTasks() {
    if (!_hasMoreData || _isLoading) return;

    _limit += 20;
    _initTaskStream();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}
