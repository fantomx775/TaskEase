import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taskease/classes/task.dart';
import 'package:taskease/enums/TaskPriority.dart';
import 'package:taskease/classes/TaskEditPopup.dart';
import 'package:taskease/classes/AddTasKPopup.dart';
import 'package:intl/intl.dart';
import 'package:taskease/classes/task_sort_widget.dart';

class TasksList extends StatefulWidget {
  late final String user;
  late final String taskTitle;

  TasksList({required this.user, required this.taskTitle});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  bool loading = false;
  List<Task> tasks = [];
  Set<int> usedIds = Set();
  late String taskTitle;
  late final String user;
  late CollectionReference _collectionRef;
  @override
  void initState() {
    super.initState();
    user = widget.user;
    taskTitle = widget.taskTitle;

    _collectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user)
        .collection('Tasks');

    initializeData();
    initializeSorting();
  }

  Future<void> initializeSorting() async {
    loading = true;
    // List<Task> taskList = [
    //   Task(
    //     id: 0,
    //     title: 'Do the dishes',
    //     priority: TaskPriority.Low,
    //     description: 'Just do it',
    //     fromDate: DateTime.now().add(Duration(days: 1)),
    //     dueDate: DateTime.now().add(Duration(days: 2)),
    //     isDone: false,
    //   ),
    //   Task(
    //     id: 1,
    //     title: 'Buy groceries',
    //     priority: TaskPriority.Medium,
    //     description: 'Get essentials for the week',
    //     fromDate: DateTime.now().add(Duration(days: 2)),
    //     dueDate: DateTime.now().add(Duration(days: 3)),
    //     isDone: false,
    //   ),
    //   Task(
    //     id: 2,
    //     title: 'Prepare presentation',
    //     priority: TaskPriority.High,
    //     description: 'Create slides and rehearse',
    //     fromDate: DateTime.now().add(Duration(days: 3)),
    //     dueDate: DateTime.now().add(Duration(days: 5)),
    //     isDone: false,
    //   ),
    //   Task(
    //     id: 3,
    //     title: 'Call mom',
    //     priority: TaskPriority.Medium,
    //     description: 'Catch up and see how she\'s doing',
    //     fromDate: DateTime.now().add(Duration(days: 1)),
    //     dueDate: DateTime.now().add(Duration(days: 1)),
    //     isDone: false,
    //   ),
    //   Task(
    //     id: 4,
    //     title: 'Go for a run',
    //     priority: TaskPriority.Low,
    //     description: 'Stay active and healthy',
    //     fromDate: DateTime.now().add(Duration(days: 2)),
    //     dueDate: DateTime.now().add(Duration(days: 2)),
    //     isDone: false,
    //   ),
    //   Task(
    //     id: 5,
    //     title: 'Read a book',
    //     priority: TaskPriority.Low,
    //     description: 'Relax and enjoy some reading time',
    //     fromDate: DateTime.now().add(Duration(days: 4)),
    //     dueDate: DateTime.now().add(Duration(days: 7)),
    //     isDone: false,
    //   ),
    //   Task(
    //     id: 6,
    //     title: 'Complete coding assignment',
    //     priority: TaskPriority.High,
    //     description: 'Finish the project on time',
    //     fromDate: DateTime.now().add(Duration(days: 3)),
    //     dueDate: DateTime.now().add(Duration(days: 6)),
    //     isDone: false,
    //   ),
    //   Task(
    //     id: 7,
    //     title: 'Plan weekend trip',
    //     priority: TaskPriority.Medium,
    //     description: 'Research destinations and make reservations',
    //     fromDate: DateTime.now().add(Duration(days: 5)),
    //     dueDate: DateTime.now().add(Duration(days: 10)),
    //     isDone: false,
    //   ),
    // ];
    // final tasksMapList = taskList.map((task) => task.toJson()).toList();
    // FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc(user)
    //     .collection('Tasks').doc(taskTitle).set({
    //     'tasks': tasksMapList,

    // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    //     .collection('Users')
    //     .doc(user)
    //     .collection('Tasks').doc(taskTitle).collection('sorting').limit(1).get();
    // print(querySnapshot.size);

    DocumentSnapshot querySnapshot = await _collectionRef.doc(taskTitle).get();

    if (!querySnapshot.exists) {
      print('Sorting does not exist. Creating one...');
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user)
          .collection('Tasks').doc(taskTitle).set
        ({
        'sorting': {
          '_currentSortOrderPriority': {2, 'Ascending'},
          '_currentSortOrderDueDate': {0, 'Ascending'},
          '_currentSortOrderFromDate': {1, 'Ascending'},
        }
      }, SetOptions(merge: true));
    }
    loading = false;
  }

  Future<void> initializeData() async {
    List<Task> fetchedTasks = await initializeTasks();
    initializeUsedIds(fetchedTasks);
  }

  void initializeUsedIds(List<Task> tasks) {
    for (Task task in tasks) {
      usedIds.add(task.id);
    }
  }

  Future<List<Task>> initializeTasks() async {
    List<Task> fetchedTasks = await getDailyTasks();
    setState(() {
      tasks = fetchedTasks;
    });
    return fetchedTasks; // Return the fetched tasks
  }

  Future<List<Task>> getDailyTasks() async {
    loading = true;
    DocumentSnapshot dailyTasksSnapshot =
        await _collectionRef.doc(taskTitle).get();

    if (dailyTasksSnapshot.exists) {
      Map<String, dynamic> dailyTasksData =
          dailyTasksSnapshot.data() as Map<String, dynamic>;

      List<dynamic> tasksJsonList = dailyTasksData['tasks'];

      List<Task> tasks = tasksJsonList
          .map<Task>((taskJson) => Task.fromJson(taskJson))
          .toList();
      loading = false;
      return tasks;
    } else {
      loading = false;
      return []; // Return an empty list if the document doesn't exist
    }

  }

  void sortTasks(List<Task> sortedTasks){
    setState(() {
      this.tasks = sortedTasks;
    });
    // print(tasks);
  }

  @override
  Widget build(BuildContext context) {
    print('User: $user');
    print(tasks);
    return loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        :
      Scaffold(
      appBar: AppBar(
        title: Text(taskTitle),
      ),
      body: Column(
        children: [
          TaskSortWidget(onSort: sortTasks, user: user, taskTitle: taskTitle, tasks: tasks),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == tasks.length) {
                  // Return an empty container if index is out of range
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: tasks[index].isDone ? Colors.green : Colors.white,
                            width: 2)),
                    color:
                        tasks[index].isDone ? Colors.lightGreen[100] : Colors.white,
                    child: ListTile(
                      key: ValueKey<int>(index),
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tasks[index].title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  tasks[index].description,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                if (tasks[index].fromDate !=
                                    null) // Display only if fromDate is not null
                                  Text(
                                    '${DateFormat('MMM d, yyyy - h:mm a').format(tasks[index].fromDate!)}',
                                    style: TextStyle(color: Colors.grey),
                                  ),

                                if (tasks[index].dueDate != null) //
                                  Text(
                                    '${DateFormat('MMM d, yyyy - h:mm a').format(tasks[index].dueDate!)} ',
                                    style: TextStyle(color: Colors.grey),
                                  ), // Display only if fromDate is not null
                                Row(
                                  children: List.generate(
                                    priorityToStarCount(tasks[index].priority),
                                    (index) => Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Handle editing task
                                      print('Edit task: ${tasks[index].title}');
                                      print(tasks[index].id);
                                      _openEditPopup(context, tasks[index]);
                                      // addTasks(tasks);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _showDeleteConfirmation(context, index);
                                    },
                                  ),
                                  if (!tasks[index].isDone)
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      color: Colors.green,
                                      onPressed: () {
                                        setState(() {
                                          tasks[index].isDone = true;
                                        });
                                        updateTaskById(tasks[index].id, tasks[index]);
                                      },
                                    ),
                                  // ... Refresh icon ...
                                  if (tasks[index].isDone)
                                    IconButton(
                                      icon: Icon(Icons.refresh),
                                      color: Colors.blue,
                                      onPressed: () {
                                        setState(() {
                                          tasks[index].isDone = false;
                                        });
                                        updateTaskById(tasks[index].id, tasks[index]);
                                      },
                                    ),
                                ],
                              ),
                              if (tasks[index].isDone)
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Task Completed!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // Handle task item tap
                        print('Task tapped: ${tasks[index].title}');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle adding new task
          _openAddPopup(context);
          print('Add new task');
          print(usedIds);
          // addTasks(tasks);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  int priorityToStarCount(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.VeryLow:
        return 1;
      case TaskPriority.Low:
        return 2;
      case TaskPriority.Medium:
        return 3;
      case TaskPriority.High:
        return 4;
      case TaskPriority.VeryHigh:
        return 5;
    }
  }

  void _openEditPopup(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskEditPopup(
          task: task,
          onTaskEdited: (editedTask) async {
            int index = tasks.indexOf(task);
            int id = tasks[index].id;
            setState(() {
              // Update the task in the list
              tasks[index] = editedTask;
            });
            await updateTaskById(id, editedTask);
          },
        );
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> updateTaskById(int id, Task editedTask) async {
    // Fetch the current array from Firestore
    DocumentSnapshot dailyTasksSnapshot = await _collectionRef.doc(taskTitle).get();

    if (dailyTasksSnapshot.exists) {
      Map<String, dynamic> dailyTasksData = dailyTasksSnapshot.data() as Map<String, dynamic>;

      List<dynamic> tasksJsonList = dailyTasksData['tasks'];

      // Find the index based on the id
      int index = tasksJsonList.indexWhere((taskJson) => taskJson['id'] == id);

      // Ensure the index is within bounds
      if (index >= 0 && index < tasksJsonList.length) {
        tasksJsonList[index] = editedTask.toJson();

        // Update the document in Firestore with the modified array
        await _collectionRef.doc(taskTitle).update({'tasks': tasksJsonList});

        print('Task with id $id updated successfully');
      } else {
        print('Task with id $id not found');
      }
    } else {
      print('Daily Tasks document does not exist.');
    }
  }

  void _openAddPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print(usedIds);
        return AddTaskPopup(
          usedIds: usedIds,
          onTaskAdded: (newTask) async{
            setState(() {
              tasks.add(newTask);
              usedIds.add(newTask.id);
            });
            await addTask(newTask);
          },
        );
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> addTask(Task task) async {
    // Fetch the current array from Firestore
    DocumentSnapshot dailyTasksSnapshot = await _collectionRef.doc(taskTitle).get();

    if (dailyTasksSnapshot.exists) {
      Map<String, dynamic> dailyTasksData = dailyTasksSnapshot.data() as Map<String, dynamic>;

      List<dynamic> tasksJsonList = dailyTasksData['tasks'];

      // Add the new task to the array
      tasksJsonList.add(task.toJson());

      // Update the document in Firestore with the modified array
      await _collectionRef.doc(taskTitle).update({'tasks': tasksJsonList});

      print('Task added successfully');
    } else {
      print('Daily Tasks document does not exist.');
    }
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    double horizontalButtonPadding = 16;
    double verticalButtonPadding = 16;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete Task: ${tasks[index].title}',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Text('Are you sure you want to delete this task?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalButtonPadding,
                              vertical: verticalButtonPadding), // Add padding
                        ),
                        child: Text('Cancel',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () {
                          if (index >= 0 && index < tasks.length) {
                            deleteTaskById(tasks[index].id);
                          }
                          setState(() {
                            if (index >= 0 && index < tasks.length) {
                              tasks.removeAt(index);
                            }
                          });
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalButtonPadding,
                              vertical: verticalButtonPadding), // Add padding
                        ),
                        child: Text('Delete',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteTaskById(int id) async {
    // Fetch the current array from Firestore
    DocumentSnapshot dailyTasksSnapshot = await _collectionRef.doc(taskTitle).get();

    if (dailyTasksSnapshot.exists) {
      Map<String, dynamic> dailyTasksData = dailyTasksSnapshot.data() as Map<String, dynamic>;

      List<dynamic> tasksJsonList = dailyTasksData['tasks'];
      int index = tasksJsonList.indexWhere((taskJson) => taskJson['id'] == id);
      // Ensure the index is within bounds
      if (index >= 0 && index < tasksJsonList.length) {
        // Remove the element at the specified index
        tasksJsonList.removeAt(index);

        // Update the document in Firestore with the modified array
        await _collectionRef.doc(taskTitle).set({'tasks': tasksJsonList});
        usedIds.remove(id);
        print('Task at index $index deleted successfully');
      } else {
        print('Invalid index');
      }
    } else {
      print('Daily Tasks document does not exist.');
    }
  }

}

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   late final String user;
//   late final String taskTitle;
//
//   @override
//   Widget build(BuildContext context) {
//     print('User: $user');
//     print('Task Title: $taskTitle');
//     return MaterialApp(
//       home: TasksList(user: user, taskTitle: taskTitle),
//     );
//   }
// }
