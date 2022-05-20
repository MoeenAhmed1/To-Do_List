import 'package:todo_list/model/subtask_model.dart';

class TaskModel {
  String taskTitle;
  DateTime dueDate;
  bool completionStatus;
  DateTime reminderAt;
  String notes;
  List<SubTask> subTasks;
  List<String> filePaths;

  TaskModel(
      {this.taskTitle,
      this.completionStatus,
      this.dueDate,
      this.notes,
      this.reminderAt,
      this.filePaths,
      this.subTasks});
}
