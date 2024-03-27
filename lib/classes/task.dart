import 'package:taskease/enums/TaskPriority.dart';

class Task{
  int id;
  String title;
  bool isDone;
  TaskPriority priority;
  String description;
  DateTime? fromDate;
  DateTime? dueDate;

  Task({required this.id, required this.title, this.isDone = false, required this.priority, required this.description, this.fromDate, this.dueDate});

  void toggleDone(){
    isDone = !isDone;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.toString().split('.').last, // Convert enum to string
      'description': description,
      'fromDate': fromDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isDone': isDone,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: _priorityFromString(json['priority']),
      description: json['description'],
      fromDate: DateTime.parse(json['fromDate']),
      dueDate: DateTime.parse(json['dueDate']),
      isDone: json['isDone'],
    );
  }

  static TaskPriority _priorityFromString(String priority) {
    switch (priority) {
      case 'VeryLow':
        return TaskPriority.VeryLow;
      case 'Low':
        return TaskPriority.Low;
      case 'Medium':
        return TaskPriority.Medium;
      case 'High':
        return TaskPriority.High;
      case 'VeryHigh':
        return TaskPriority.VeryHigh;
      default:
        throw Exception('Unknown priority: $priority');
    }
  }
}