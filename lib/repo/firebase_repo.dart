import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/photoitem_model.dart';
import 'package:todo_list/model/subtask_model.dart';
import 'package:todo_list/model/task_model.dart';
import 'package:todo_list/model/user_model.dart';

class FirebaseRepo {
  String idUser;
  FirebaseRepo({this.idUser});
  final refUsers = FirebaseFirestore.instance.collection('UserTasksList');
  final refTasks = FirebaseFirestore.instance.collection('TasksLists');
  final refPhotoList = FirebaseFirestore.instance.collection('PhotoLists');
  Future<String> getUserName() async {
    var data;
    UserData userData;
    try {
      data = await refUsers.doc(idUser).get();

      userData = UserData.fromJson(data.data());
    } catch (e) {
      print(e);
    }
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

  Future uploadPhotoList(String listTitle) async {
    await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .add({'listtitle': listTitle});
  }

  Future updatePhotoList(String listTitle, int listId) async {
    String id = await photoListDocId(listId);

    await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .doc(id)
        .update({'listtitle': listTitle});
  }

  Future deletePhotoList(int listId) async {
    String id = await docId(listId);
    await refUsers.doc(idUser).collection('PhotoLists').doc(id).delete();
  }

  Future uploadPhotoListItem(String uploadPath, int i) async {
    String id = await photoListDocId(i);
    await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .doc(id)
        .collection('tasks')
        .add({'picture': uploadPath, 'completionstatus': false});
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

  Future updateTask(bool isCompleted, int i, int taskListIndex,
      {String taskTitle, bool isPhotoPage}) async {
    if (isPhotoPage) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .update({
        'completionstatus': isCompleted,
      });
    } else {
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
  }

  Future deleteTask(int i, int taskListIndex, {bool isPhotoPage}) async {
    if (isPhotoPage) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .delete();
    } else {
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
  }

  Future uploadTaskCompletionStatus(int i, bool isCompleted) async {
    String id = await docId(i);
    await refTasks
        .doc(idUser)
        .collection("Tasks")
        .doc(id)
        .set({'completionstatus': isCompleted});
  }

//1
  Future uploadTaskDueDate(int i, DateTime dueDate, int taskListIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .update({'taskduedate': dueDate.toString()});
    } else {
      String id = await docId(i);
      String listId = await taskDocId(taskListIndex, id);

      await refUsers
          .doc(idUser)
          .collection("TasksLists")
          .doc(id)
          .collection('Tasks')
          .doc(listId)
          .update({'taskduedate': dueDate.toString()});
    }
  }

//2
  Future uploadTaskReminderAt(int i, DateTime reminderAt, int taskListIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .update({'taskreminderat': reminderAt.toString()});
    } else {
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
  }

//3
  Future uploadTaskNotes(int i, String notes, int taskListIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .update({'notes': notes});
    } else {
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
  }

  Future uploadTaskStarredStatus(int i, bool isStarred) async {
    String id = await docId(i);
    await refTasks
        .doc(idUser)
        .collection("Tasks")
        .doc(id)
        .set({'StarredStatus': isStarred});
  }

  Future uploadFile(int i, String filePath, int taskListIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .collection("Attachments")
          .add({'fileurl': filePath});
    } else {
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
  }

  Future uploadSubTasks(int i, SubTask subTask, int taskListIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .collection("SubTasks")
          .add({
        'subTaskTitle': subTask.taskTitle,
        'IsCompleted': subTask.completionStatus
      });
    } else {
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
  }

  Future updateSubTasks(
      int i, SubTask subTask, int taskListIndex, int subTaskIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      String subTaskId = await photoListSubTaskDocId(subTaskIndex, id, listId);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .collection("SubTasks")
          .doc(subTaskId)
          .update({
        'subTaskTitle': subTask.taskTitle,
        'IsCompleted': subTask.completionStatus
      });
    } else {
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
  }

  Future deleteSubTasks(int i, int taskListIndex, int subTaskIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      String subTaskId = await photoListSubTaskDocId(subTaskIndex, id, listId);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .collection("SubTasks")
          .doc(subTaskId)
          .delete();
    } else {
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
          .delete();
    }
  }

  Future deleteTasksFiles(int i, int taskListIndex, int taskFileIndex,
      {bool isPhotoList = false}) async {
    if (isPhotoList) {
      String id = await photoListDocId(i);
      String listId = await photoListItemDocId(id, taskListIndex);
      String subTaskId = await photoListFileDocID(taskFileIndex, id, listId);
      await refUsers
          .doc(idUser)
          .collection("PhotoLists")
          .doc(id)
          .collection('tasks')
          .doc(listId)
          .collection("Attachments")
          .doc(subTaskId)
          .delete();
    } else {
      String id = await docId(i);
      String listId = await taskDocId(taskListIndex, id);
      String subTaskId = await taskFileDocID(taskFileIndex, id, listId);
      await refUsers
          .doc(idUser)
          .collection("TasksLists")
          .doc(id)
          .collection('Tasks')
          .doc(listId)
          .collection("Attachments")
          .doc(subTaskId)
          .delete();
    }
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

  Future<List<String>> getPhotoLists() async {
    final stream = await refUsers.doc(idUser).collection('PhotoLists').get();

    List list = stream.docs.toList();
    List<String> photoLists = [];
    for (int i = 0; i < list.length; i++) {
      //int index = list[i]['index'];
      photoLists.add(list[i]['listtitle']);
      //taskLists[index] = list[i]['listtitle'];
    }
    return photoLists;
  }

  Future<List<PhotoItemModel>> getPhotoItem(int index) async {
    String id = await photoListDocId(index);
    final stream = await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .doc(id)
        .collection('tasks')
        .get();
    final list = stream.docs.toList();
    List<PhotoItemModel> photoItemList = [];
    for (int i = 0; i < list.length; i++) {
      PhotoItemModel item = PhotoItemModel(
          imgURL: list[i].data()['picture'],
          completionStatus: list[i].data()['completionstatus']);
      photoItemList.add(item);
    }
    return photoItemList;
  }

  Future<List<PhotoItemModel>> getPhotoItemDetails(int index) async {
    String id = await photoListDocId(index);
    final stream = await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .doc(id)
        .collection('tasks')
        .get();
    final list = stream.docs.toList();
    List<PhotoItemModel> photoItemList = [];
    for (int i = 0; i < list.length; i++) {
      PhotoItemModel item = PhotoItemModel(
          dueDate: list[i].data()['taskduedate'] != null
              ? DateTime.parse(list[i]["taskduedate"])
              : null,
          reminderAt: list[i].data()['taskreminderat'] != null
              ? DateTime.parse(list[i]["taskreminderat"])
              : null,
          notes: list[i].data()['notes'] != null ? list[i]["notes"] : 'null');
      photoItemList.add(item);
    }
    return photoItemList;
  }

  Future<List> getTaskDetails(int index) async {
    String id = await docId(index);
    final stream = await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection('Tasks')
        .get();
    //taskreminderat
    final list = stream.docs.toList();
    List<TaskModel> taskList = [];
    for (int i = 0; i < list.length; i++) {
      TaskModel task = TaskModel(
          taskTitle: list[i].data()['tasktitle'] ?? '',
          completionStatus: list[i].data()['completionstatus'] ?? false,
          dueDate: list[i].data()['taskduedate'] != null
              ? DateTime.parse(list[i]["taskduedate"])
              : null,
          reminderAt: list[i].data()['taskreminderat'] != null
              ? DateTime.parse(list[i]["taskreminderat"])
              : null,
          notes: list[i].data()['notes'] != null ? list[i]["notes"] : 'null');

      taskList.add(task);
    }

    return taskList;
  }

  Future<List> getSubTasks(int index, int taskIndex,
      {bool isPhotoList = false}) async {
    QuerySnapshot stream;
    if (isPhotoList) {
      String id = await photoListDocId(index);
      String subTaskId = await photoListItemDocId(id, taskIndex);
      stream = await refUsers
          .doc(idUser)
          .collection('PhotoLists')
          .doc(id)
          .collection('tasks')
          .doc(subTaskId)
          .collection('SubTasks')
          .get();
    } else {
      String id = await docId(index);
      String subTaskId = await taskDocId(taskIndex, id);
      stream = await refUsers
          .doc(idUser)
          .collection('TasksLists')
          .doc(id)
          .collection('Tasks')
          .doc(subTaskId)
          .collection('SubTasks')
          .get();
    }

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

  Future<void> storeImageAndNotes(File imgFile, int i) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    String fileName = imgFile.path.split('/').last;
    Reference reference = firebaseStorage.ref().child(idUser).child(fileName);
    UploadTask uploadTask = reference.putFile(File(imgFile.path));
    uploadTask.snapshotEvents.listen((event) {});

    await uploadTask.whenComplete(() async {
      final uploadPath = await uploadTask.snapshot.ref.getDownloadURL();
      await uploadPhotoListItem(uploadPath, i);
    });
  }

  Future<void> deleteImageFromStorage(String imgURL) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    await firebaseStorage.refFromURL(imgURL).delete();
  }

  Future<List> getFiles(int index, int taskIndex,
      {bool isPhotoList = false}) async {
    QuerySnapshot stream;
    if (isPhotoList) {
      String id = await photoListDocId(index);
      String subTaskId = await photoListItemDocId(id, taskIndex);
      stream = await refUsers
          .doc(idUser)
          .collection('PhotoLists')
          .doc(id)
          .collection('tasks')
          .doc(subTaskId)
          .collection('Attachments')
          .get();
    } else {
      String id = await docId(index);
      String subTaskId = await taskDocId(taskIndex, id);
      stream = await refUsers
          .doc(idUser)
          .collection('TasksLists')
          .doc(id)
          .collection('Tasks')
          .doc(subTaskId)
          .collection('Attachments')
          .get();
    }

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

  Future<String> photoListDocId(int i) async {
    QuerySnapshot querySnapshot =
        await refUsers.doc(idUser).collection('PhotoLists').get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }

  Future<String> photoListItemDocId(String id, int i) async {
    QuerySnapshot querySnapshot = await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .doc(id)
        .collection('tasks')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }

  Future<String> taskDocId(int i, String id) async {
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

  Future<String> photoListSubTaskDocId(int i, String id, String taskId) async {
    QuerySnapshot querySnapshot = await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .doc(id)
        .collection('tasks')
        .doc(taskId)
        .collection('SubTasks')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }

  Future<String> photoListFileDocID(int i, String id, String taskId) async {
    QuerySnapshot querySnapshot = await refUsers
        .doc(idUser)
        .collection('PhotoLists')
        .doc(id)
        .collection('tasks')
        .doc(taskId)
        .collection('Attachments')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }

  Future<String> taskFileDocID(int i, String id, String taskId) async {
    QuerySnapshot querySnapshot = await refUsers
        .doc(idUser)
        .collection('TasksLists')
        .doc(id)
        .collection('Tasks')
        .doc(taskId)
        .collection('Attachments')
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      List list = querySnapshot.docs.toList();
      return list[i].id;
    }
    return "0";
  }
}
