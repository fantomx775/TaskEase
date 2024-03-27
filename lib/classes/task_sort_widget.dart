import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskease/classes/task.dart';

enum SortOrder {
  Ascending,
  Descending,
}

enum TaskSortingCriteria {
  Priority,
  DueDate,
  FromDate,
}

class TaskSortWidget extends StatefulWidget {
  final Function(List<Task>) onSort;
  final String user;
  final String taskTitle;
  final List<Task> tasks;

  TaskSortWidget(
      {required this.onSort,
      required this.user,
      required this.taskTitle,
      required this.tasks});

  @override
  _TaskSortWidgetState createState() => _TaskSortWidgetState();
}

class _TaskSortWidgetState extends State<TaskSortWidget> {
  bool loading = false;
  late List<Task> tasks;
  late CollectionReference _collectionRef;
  late final String taskTitle;
  late final String user;
  late Map<String, dynamic> sorting;

  void initState() {
    print('init sort widget');
    super.initState();
    setState(() {
      user = widget.user;
      taskTitle = widget.taskTitle;
    });
    tasks = widget.tasks;

    _collectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user)
        .collection('Tasks');
    initializeSorting();
  }

  Future<void> initializeSorting() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot querySnapshot = await _collectionRef.doc(taskTitle).get();

    if (querySnapshot.exists) {
      Map<String, dynamic> data = querySnapshot.data() as Map<String, dynamic>;
      setState(() {
        sorting = data['sorting'];

      });
    } else {
      print(
          '(sort widget, this message should never show!) Sorting does not exist. Creating one...');
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user)
          .collection('Tasks')
          .doc(taskTitle)
          .set({
        'sorting': {
          '_currentSortOrderPriority': {2, 'Ascending'},
          '_currentSortOrderDueDate': {0, 'Ascending'},
          '_currentSortOrderFromDate': {1, 'Ascending'},
        }
      }, SetOptions(merge: true));
    }
    setState(() {
      loading = false;
    });
    sortTasks();
  }

  void sortTasks() {
    for (int i = 0; i < sorting.length; i++) {
      for (var entry in sorting.entries) {
        if (entry.value[0] == i) {
          SortOrder sortOrder = entry.value[1] == 'Ascending'
              ? SortOrder.Ascending
              : SortOrder.Descending;
          switch (entry.key) {
            case '_currentSortOrderPriority':
              tasks.sort((a, b) =>
                  a.priority.index.compareTo(b.priority.index) *
                  (sortOrder == SortOrder.Ascending ? 1 : -1));
              break;
            case '_currentSortOrderDueDate':
              tasks.sort((a, b) =>
                  a.dueDate!.compareTo(b.dueDate!) *
                  (sortOrder == SortOrder.Ascending ? 1 : -1));
              break;
            case '_currentSortOrderFromDate':
              tasks.sort((a, b) =>
                  a.fromDate!.compareTo(b.fromDate!) *
                  (sortOrder == SortOrder.Ascending ? 1 : -1));
              break;
          }
        }
      }
    }
    widget.onSort(tasks);
  }

  void _cycleSortOrder(TaskSortingCriteria sortingCriteria) {
    setState(() {
      switch (sortingCriteria) {
        case TaskSortingCriteria.Priority:
          sorting['_currentSortOrderPriority'][1] =
              sorting['_currentSortOrderPriority'][1] == 'Ascending'
                  ? 'Descending'
                  : 'Ascending';
          switch (sorting['_currentSortOrderPriority'][0]) {
            case 0:
              sorting['_currentSortOrderPriority'][0] = 2;
              sorting['_currentSortOrderDueDate'][0]--;
              sorting['_currentSortOrderFromDate'][0]--;
              break;
            case 1:
              sorting['_currentSortOrderPriority'][0] = 2;
              if (sorting['_currentSortOrderDueDate'][0] == 2)
                sorting['_currentSortOrderDueDate'][0] = 1;
              else
                sorting['_currentSortOrderFromDate'][0] = 1;
              break;
            case 2:
              break;
          }
          break;
        case TaskSortingCriteria.DueDate:
          sorting['_currentSortOrderDueDate'][1] =
              sorting['_currentSortOrderDueDate'][1] == 'Ascending'
                  ? 'Descending'
                  : 'Ascending';
          switch (sorting['_currentSortOrderDueDate'][0]) {
            case 0:
              sorting['_currentSortOrderDueDate'][0] = 2;
              sorting['_currentSortOrderPriority'][0]--;
              sorting['_currentSortOrderFromDate'][0]--;
              break;
            case 1:
              sorting['_currentSortOrderDueDate'][0] = 2;
              if (sorting['_currentSortOrderPriority'][0] == 2)
                sorting['_currentSortOrderPriority'][0] = 1;
              else
                sorting['_currentSortOrderFromDate'][0] = 1;
              break;
            case 2:
              break;
          }
          break;
        case TaskSortingCriteria.FromDate:
          sorting['_currentSortOrderFromDate'][1] =
              sorting['_currentSortOrderFromDate'][1] == 'Ascending'
                  ? 'Descending'
                  : 'Ascending';
          switch (sorting['_currentSortOrderFromDate'][0]) {
            case 0:
              sorting['_currentSortOrderFromDate'][0] = 2;
              sorting['_currentSortOrderPriority'][0]--;
              sorting['_currentSortOrderDueDate'][0]--;
              break;
            case 1:
              sorting['_currentSortOrderFromDate'][0] = 2;
              if (sorting['_currentSortOrderPriority'][0] == 2)
                sorting['_currentSortOrderPriority'][0] = 1;
              else
                sorting['_currentSortOrderDueDate'][0] = 1;
              break;
            case 2:
              break;
          }
          break;
      }
    });
    updateSorting();
    sortTasks();
  }

  Future<void> updateSorting() async {
    await _collectionRef.doc(taskTitle).set({
      'sorting': toJson(),
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> toJson() {
    return {
      '_currentSortOrderPriority': {
        sorting['_currentSortOrderPriority'][0],
        sorting['_currentSortOrderPriority'][1],
      },
      '_currentSortOrderDueDate': {
        sorting['_currentSortOrderDueDate'][0],
        sorting['_currentSortOrderDueDate'][1],
      },
      '_currentSortOrderFromDate': {
        sorting['_currentSortOrderFromDate'][0],
        sorting['_currentSortOrderFromDate'][1],
      },
    };
  }

  Widget _buildSortButton(String label, TaskSortingCriteria sortingCriteria) {
    IconData icon;
    switch (sortingCriteria) {
      case TaskSortingCriteria.Priority:
        icon = sorting['_currentSortOrderPriority'][1] == SortOrder.Ascending
            ? Icons.arrow_upward
            : Icons.arrow_downward;
                break;
      case TaskSortingCriteria.DueDate:
        icon = sorting['_currentSortOrderDueDate'][1] == SortOrder.Ascending
            ? Icons.arrow_upward
            : Icons.arrow_downward;
        break;
      case TaskSortingCriteria.FromDate:
        icon = sorting['_currentSortOrderFromDate'][1] == SortOrder.Ascending
            ? Icons.arrow_upward
            : Icons.arrow_downward;
        break;
      default:
        print('error');
        icon = Icons.error;
    }

    return ElevatedButton.icon(
      onPressed: () {
        print('sorting by $sortingCriteria');
        _cycleSortOrder(sortingCriteria);
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        :
      Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSortButton('Sort by Priority', TaskSortingCriteria.Priority),
        SizedBox(width: 6),
        _buildSortButton('Sort by Due Date', TaskSortingCriteria.DueDate),
        SizedBox(width: 6),
        _buildSortButton('Sort by From Date', TaskSortingCriteria.FromDate),
      ],
    );
  }
}
