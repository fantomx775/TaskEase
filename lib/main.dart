import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskease/views/home.dart';
import 'package:taskease/views/tasks_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp.router(
    title: 'Taskease',
    routerConfig: _router,
  ));

}
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => Home(),
    ),
    GoRoute(
      path: '/tasks_list/:user/:taskTitle',
      builder: (context, state) => TasksList(
        user: state.pathParameters['user']!,
        taskTitle: state.pathParameters['taskTitle']!,
      ),
    ),
  ],
);
