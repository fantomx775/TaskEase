import 'package:flutter/material.dart';
import 'package:taskease/classes/task.dart';
import 'package:taskease/enums/TaskPriority.dart';
import 'package:intl/intl.dart';

class TaskEditPopup extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskEdited;

  TaskEditPopup({required this.task, required this.onTaskEdited});

  @override
  _TaskEditPopupState createState() => _TaskEditPopupState();
}

class _TaskEditPopupState extends State<TaskEditPopup> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _selectedPriority;
  late DateTime? _selectedDueDateTime;
  late DateTime? _selectedFromDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedPriority = widget.task.priority;
    _selectedDueDateTime = widget.task.dueDate;
    _selectedFromDateTime = widget.task.fromDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Set circular corners for the Dialog
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: Center(child: Text('Edit Task')),
              actions: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  Text('Select Priority:'),
                  Row(
                    children: List.generate(
                      5,
                          (index) {
                        int starCount = index + 1;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPriority = _priorityFromStarCount(starCount);
                            });
                          },
                          child: Icon(
                            Icons.star,
                            color: _selectedPriority.index >= starCount - 1
                                ? Colors.orange
                                : Colors.grey,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text('Select From Date:'),
                          Spacer(),
                          InkWell(
                            onTap: () async {
                              DateTime? pickedDateTime = await showDatePicker(
                                context: context,
                                initialDate: _selectedFromDateTime ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (pickedDateTime != null) {
                                setState(() {
                                  _selectedFromDateTime = pickedDateTime;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 8),
                                Text(DateFormat('MMM d, yyyy').format(_selectedFromDateTime ?? DateTime.now())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Select From Time:'),
                          Spacer(),
                          InkWell(
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_selectedFromDateTime ?? DateTime.now()),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedFromDateTime = DateTime(
                                    _selectedFromDateTime?.year ?? DateTime.now().year,
                                    _selectedFromDateTime?.month ?? DateTime.now().month,
                                    _selectedFromDateTime?.day ?? DateTime.now().day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.access_time),
                                SizedBox(width: 8),
                                Text(DateFormat('h:mm a').format(_selectedFromDateTime ?? DateTime.now())),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Text('Select Due Date:'),
                          Spacer(),
                          InkWell(
                            onTap: () async {
                              DateTime? pickedDateTime = await showDatePicker(
                                context: context,
                                initialDate: _selectedDueDateTime ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(Duration(days: 365)),
                              );
                              if (pickedDateTime != null) {
                                setState(() {
                                  _selectedDueDateTime = pickedDateTime;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 8),
                                Text(DateFormat('MMM d, yyyy').format(_selectedDueDateTime ?? DateTime.now())),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Select Due Time:'),
                          Spacer(),
                          InkWell(
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_selectedDueDateTime ?? DateTime.now()),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedDueDateTime = DateTime(
                                    _selectedDueDateTime?.year ?? DateTime.now().year,
                                    _selectedDueDateTime?.month ?? DateTime.now().month,
                                    _selectedDueDateTime?.day ?? DateTime.now().day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Icon(Icons.access_time),
                                SizedBox(width: 8),
                                Text(DateFormat('h:mm a').format(_selectedDueDateTime ?? DateTime.now())),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Handle editing the task
                      widget.task.title = _titleController.text;
                      widget.task.description = _descriptionController.text;
                      widget.task.priority = _selectedPriority;
                      if(_selectedFromDateTime!.compareTo(_selectedDueDateTime!) < 0){
                        widget.task.fromDate = _selectedFromDateTime;
                        widget.task.dueDate = _selectedDueDateTime;
                      }
                      widget.onTaskEdited(widget.task); // Notify parent about task edit
                      Navigator.of(context).pop(); // Close the popup
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TaskPriority _priorityFromStarCount(int starCount) {
    switch (starCount) {
      case 1:
        return TaskPriority.VeryLow;
      case 2:
        return TaskPriority.Low;
      case 3:
        return TaskPriority.Medium;
      case 4:
        return TaskPriority.High;
      case 5:
        return TaskPriority.VeryHigh;
      default:
        return TaskPriority.Medium; // Default to Medium
    }
  }
}
