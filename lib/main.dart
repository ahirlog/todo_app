import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/services/firebase_service.dart';
import 'package:todo_app/viewmodels/task_viewmodel.dart';
import 'package:todo_app/views/screens/tasks_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ],
      child: MaterialApp(
        title: 'Flutter TODO App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: TasksScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
