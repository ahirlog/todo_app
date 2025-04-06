import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/viewmodels/task_viewmodel.dart';
import 'package:todo_app/views/screens/add_edit_task_screen.dart';
import 'package:todo_app/views/widgets/task_list.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO App'),
        centerTitle: true,
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          if (taskViewModel.isLoading && taskViewModel.tasks.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return TaskList(
            tasks: taskViewModel.tasks,
            onLoadMore: taskViewModel.loadMoreTasks,
            hasMoreData: taskViewModel.hasMoreData,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditTaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
