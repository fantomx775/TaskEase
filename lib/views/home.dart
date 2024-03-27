import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taskease/enums/TaskPriority.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pretty Tiles Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TileRow(),
            SizedBox(height: 16.0),
            TileRow(),
          ],
        ),
      ),
    );
  }
}

class TileRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
            child: PrettyTile(title: 'Daily Tasks', color: Colors.blue),
            onTap: () {
              print('Daily tapped');
              String user = 'User0';
              String taskTitle = 'Daily Tasks';
              GoRouter.of(context).push('/tasks_list/$user/$taskTitle');
            }
        ),
        GestureDetector(
            child: PrettyTile(title: 'Weekly Tasks', color: Colors.green),
            onTap: () {
              print('Weekly tapped');
            }
        ),
      ],
    );
  }
}

class PrettyTile extends StatelessWidget {
  final String title;
  final Color color;

  PrettyTile({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.9),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
