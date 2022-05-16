import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/subtask_model.dart';
import 'package:todo_list/model/task_model.dart';
import 'package:todo_list/model/user_model.dart';

class FirebaseRepo {
  String idUser;
  FirebaseRepo({this.idUser});
  final refUsers = FirebaseFirestore.instance.collection('UserTasksList');
  final refTasks = FirebaseFirestore.instance.collection('TasksLists');
  Future<String> getUserName() async {
    var data;
    UserData userData;
    try {
      data = await refUsers.doc(idUser).get();

      userData = UserData.fromJson(data.data());
    } catch (e) {
      print(e);
    }
    print(userData.name);
    return userData.name;
  }

  Future addUser(UserData user) async {
    await refUsers.doc(idUser).set(user.toJson());
  }

  Future uploadTaskList(String listTitle, int index) async {
    await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .add({'listtitle': listTitle, 'index': index});
  }

  Future updateTaskListIndex(int oldIndex, int newIndex) async {
    String id = await docId(oldIndex);
    await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .update({'index': newIndex});
  }

  Future updateTaskList(String listTitle, int listId) async {
    String id = await docId(listId);
    await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .update({'listtitle': listTitle});
  }

  Future deleteTaskList(int listId) async {
    String id = await docId(listId);
    await refUsers.doc(idUser).collection('TasksLists').doc(id).delete();
  }

  Future uploadTaskTitle(String taskTitle, bool isCompleted, int i) async {
    String id = await docId(i);

    await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection("Tasks")
        .add({
      'tasktitle': taskTitle,
      'completionstatus': isCompleted,
      'taskduedate': null,
      'taskreminderat': null,
      'notes': null,
    });
  }

  Future updateTask(
      String taskTitle, bool isCompleted, int i, int taskListIndex) async {
    String id = await docId(i);
    String listId = await taskDocId(taskListIndex, id);
    await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection("Tasks")
        .doc(listId)
        .update({
      'tasktitle': taskTitle,
      'completionstatus': isCompleted,
    });
  }

  Future deleteTask(int i, int taskListIndex) async {
    String id = await docId(i);
    String listId = await taskDocId(taskListIndex, id);
    await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection("Tasks")
        .doc(listId)
        .delete();
  }

  Future uploadTaskCompletionStatus(int i, bool isCompleted) async {
    String id = await docId(i);
    await refTasks
        .doc(idUser)
        .collection("Tasks")
        .doc(id)
        .set({'completionstatus': isCompleted});
  }

  Future uploadTaskDueDate(int i, DateTime dueDate, int taskListIndex) async {
    String id = await docId(i);
    print("moo");
    print(id);
    print("moo");
    String listId = await taskDocId(taskListIndex, id);

    await refUsers
        .doc(idUser)
        .collection("TasksLists")
        .doc(id)
        .collection('Tasks')
        .doc(listId)
        .update({'taskduedate': dueDate.toString()});
  }

  Future uploadTaskReminderAt(
      int i, TimeOfDay reminderAt, int taskListIndex) async {
    String id = await docId(i);
    String listId = await taskDocId(taskListIndex, id);
    await refUsers
        .doc(idUser)
        .collection("TasksLists")
        .doc(id)
        .collection('Tasks')
        .doc(listId)
        .update({'taskreminderat': reminderAt.toString()});
  }

  Future uploadTaskNotes(int i, String notes, int taskListIndex) async {
    String id = await docId(i);
    String listId = await taskDocId(taskListIndex, id);
    await refUsers
        .doc(idUser)
        .collection("TasksLists")
        .doc(id)
        .collection('Tasks')
        .doc(listId)
        .update({'notes': notes});
  }

  Future uploadTaskStarredStatus(int i, bool isStarred) async {
    String id = await docId(i);
    await refTasks
        .doc(idUser)
        .collection("Tasks")
        .doc(id)
        .set({'StarredStatus': isStarred});
  }

  Future uploadFile(int i, String filePath, int taskListIndex) async {
    String id = await docId(i);
    String listId = await taskDocId(taskListIndex, id);
    await refUsers
        .doc(idUser)
        .collection("TasksLists")
        .doc(id)
        .collection('Tasks')
        .doc(listId)
        .collection("Attachments")
        .add({'fileurl': filePath});
  }

  Future uploadSubTasks(int i, SubTask subTask, int taskListIndex) async {
    String id = await docId(i);
    String listId = await taskDocId(taskListIndex, id);
    await refUsers
        .doc(idUser)
        .collection("TasksLists")
        .doc(id)
        .collection('Tasks')
        .doc(listId)
        .collection("SubTasks")
        .add({
      'subTaskTitle': subTask.taskTitle,
      'IsCompleted': subTask.completionStatus
    });
  }

  Future updateSubTasks(
      int i, SubTask subTask, int taskListIndex, int subTaskIndex) async {
    String id = await docId(i);
    String listId = await taskDocId(taskListIndex, id);
    String subTaskId = await subTaskDocId(subTaskIndex, id, listId);
    await refUsers
        .doc(idUser)
        .collection("TasksLists")
        .doc(id)
        .collection('Tasks')
        .doc(listId)
        .collection("SubTasks")
        .doc(subTaskId)
        .update({
      'subTaskTitle': subTask.taskTitle,
      'IsCompleted': subTask.completionStatus
    });
  }

  Future<List<String>> getTaskLists() async {
    final stream = await refUsers.doc(idUser).collection('TasksLists').get();

    List list = stream.docs.toList();
    List<String> taskLists = [];
    for (int i = 0; i < list.length; i++) {
      taskLists.add('');
    }
    for (int i = 0; i < list.length; i++) {
      int index = list[i]['index'];
      //taskLists.add(list[i]['listtitle']);
      taskLists[index] = list[i]['listtitle'];
    }

    return taskLists;
  }

  Future<List> getTaskDetails(int index) async {
    String id = await docId(index);
    final stream = await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection('Tasks')
        .get();
    final list = stream.docs.toList();
    List<TaskModel> taskList = [];
    for (int i = 0; i < list.length; i++) {
      TaskModel task = TaskModel(
          taskTitle: list[i].data()['tasktitle'] ?? '',
          completionStatus: list[i].data()['completionstatus'] ?? false,
          dueDate: list[i].data()['taskduedate'] != null
              ? DateTime.parse(list[i]["taskduedate"])
              : DateTime.now(),
          reminderAt: list[i].data()['taskreminderat'] != null
              ? list[i]["taskreminderat"].toString().substring(
                  10, list[i]["taskreminderat"].toString().length - 1)
              : 'null',
          notes: list[i].data()['notes'] != null ? list[i]["notes"] : 'null');

      taskList.add(task);
    }

    return taskList;
  }

  Future<List> getSubTasks(int index, int taskIndex) async {
    String id = await docId(index);
    String subTaskId = await taskDocId(taskIndex, id);
    final stream = await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection('Tasks')
        .doc(subTaskId)
        .collection('SubTasks')
        .get();
    List list = stream.docs.toList();
    List<SubTask> subTaskList = [];
    for (int i = 0; i < list.length; i++) {
      SubTask subTask = SubTask(
          completionStatus: (list[i].data()['IsCompleted'] != null)
              ? list[i]["IsCompleted"]
              : false,
          taskTitle: (list[i].data()['subTaskTitle'] != null)
              ? list[i]["subTaskTitle"]
              : "");
      subTaskList.add(subTask);
    }
    return subTaskList;
  }

  Future<List> getFiles(int index, int taskIndex) async {
    String id = await docId(index);
    String subTaskId = await taskDocId(taskIndex, id);
    final stream = await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection('Tasks')
        .doc(subTaskId)
        .collection('Attachments')
        .get();
    List list = stream.docs.toList();
    List<String> urlList = [];
    for (int i = 0; i < list.length; i++) {
      urlList.add(list[i]["fileurl"]);
    }
    return urlList;
  }

  Future<String> docId(int i) async {
    QuerySnapshot querySnapshot =
        await refUsers.doc(idUser).collection('TasksLists').get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }

  Future<String> taskDocId(int i, String id) async {
    print(i);
    QuerySnapshot querySnapshot = await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection('Tasks')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }

  Future<String> subTaskDocId(int i, String id, String taskId) async {
    print(i);
    QuerySnapshot querySnapshot = await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection('Tasks')
        .doc(taskId)
        .collection('SubTasks')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }
}
