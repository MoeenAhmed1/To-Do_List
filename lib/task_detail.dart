import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/file_viewer.dart';
import 'package:todo_list/model/subtask_model.dart';
import 'package:todo_list/model/task_model.dart';
import 'package:todo_list/model/user_model.dart';
import 'package:todo_list/repo/firebase_repo.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TaskDetailPage extends StatefulWidget {
  final UserData userData;
  final String title;
  final int index;
  final int mainListIndex;
  TaskModel task;
  TaskDetailPage(
      {this.userData, this.title, this.index, this.mainListIndex, this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  List<String> subTask = [];
  List<TaskModel> tasks = [];
  String valueText = "";
  String displayDate = "";
  String notes = "";
  String uploadPath;
  DateTime date;
  TimeOfDay selectedTime = TimeOfDay.now();
  String DisplayTime;
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _notesFieldController = TextEditingController();
  List<PlatformFile> fileList = [];
  bool loading = true;
  List<SubTask> subtasklist = [];
  List urlList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getSubTask();
  }

  getSubTask() async {
    subtasklist = await FirebaseRepo(idUser: widget.userData.uid)
        .getSubTasks(widget.mainListIndex, widget.index);
    urlList = await FirebaseRepo(idUser: widget.userData.uid)
        .getFiles(widget.mainListIndex, widget.index);
    tasks = await FirebaseRepo(idUser: widget.userData.uid)
        .getTaskDetails(widget.mainListIndex);
    widget.task = tasks[widget.index];
    if (widget.task.notes != null && !widget.task.notes.contains('null')) {
      _notesFieldController.text = widget.task.notes;
    } else if (widget.task.notes.contains('null')) {
      _notesFieldController.clear();
    } else {
      _notesFieldController.text = widget.task.notes;
    }
    if (widget.task.reminderAt != null || widget.task.reminderAt != 'null') {
      DisplayTime = widget.task.reminderAt;
    }
    if (widget.task.reminderAt == 'null') {
      DisplayTime = '';
    }
    if (widget.task.dueDate != null || widget.task.dueDate.year != 1960) {
      displayDate = DateFormat.yMMMEd().format(widget.task.dueDate);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.star_border,
              color: Colors.grey,
            ),
          )
        ],
      ),
      body: (loading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                notes = _notesFieldController.text;
                FirebaseRepo(idUser: widget.userData.uid)
                    .uploadTaskNotes(widget.mainListIndex, notes, widget.index);
                if (notes.isEmpty) {
                  _notesFieldController.clear();
                }
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2015),
                                  lastDate: DateTime(2030));
                              setState(() {
                                displayDate = DateFormat.yMMMEd().format(date);
                              });

                              FirebaseRepo(idUser: widget.userData.uid)
                                  .uploadTaskDueDate(
                                      widget.mainListIndex, date, widget.index);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  (displayDate.isEmpty)
                                      ? "Add Due Date"
                                      : "Due $displayDate",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay timeOfDay = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                                initialEntryMode: TimePickerEntryMode.dial,
                              );
                              if (timeOfDay != null &&
                                  timeOfDay != selectedTime) {
                                setState(() {
                                  DisplayTime = timeOfDay.toString().substring(
                                      10, timeOfDay.toString().length - 1);
                                });
                                FirebaseRepo(idUser: widget.userData.uid)
                                    .uploadTaskReminderAt(widget.mainListIndex,
                                        timeOfDay, widget.index);
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Remind me at $DisplayTime",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Never Repeat",
                                style:
                                    TextStyle(fontSize: 22, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          Container(
                            height: 60.0 * (subtasklist.length + 1),
                            child: ListView.builder(
                                itemCount: subtasklist.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == subtasklist.length) {
                                    return ListTile(
                                      onTap: () {
                                        _displayTextInputDialog(context);
                                      },
                                      leading: Icon(
                                        Icons.add,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                      title: Text(
                                        "Add a Subtask",
                                        style: TextStyle(
                                            fontSize: 22, color: Colors.grey),
                                      ),
                                    );
                                  } else {
                                    return ListTile(
                                      leading: (subtasklist[index]
                                                  .completionStatus ??
                                              false)
                                          ? InkWell(
                                              onTap: () {
                                                subtasklist[index]
                                                    .completionStatus = true;
                                                SubTask task = SubTask(
                                                    completionStatus:
                                                        subtasklist[index]
                                                            .completionStatus,
                                                    taskTitle:
                                                        subtasklist[index]
                                                            .taskTitle);
                                                setState(() {});
                                                FirebaseRepo(
                                                        idUser:
                                                            widget.userData.uid)
                                                    .updateSubTasks(
                                                        widget.mainListIndex,
                                                        task,
                                                        widget.index,
                                                        index);
                                              },
                                              child: Icon(Icons.check_box,
                                                  color: Colors.green,
                                                  size: 30),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                subtasklist[index]
                                                    .completionStatus = false;
                                                SubTask task = SubTask(
                                                    completionStatus:
                                                        subtasklist[index]
                                                            .completionStatus,
                                                    taskTitle:
                                                        subtasklist[index]
                                                            .taskTitle);
                                                setState(() {});
                                                FirebaseRepo(
                                                        idUser:
                                                            widget.userData.uid)
                                                    .updateSubTasks(
                                                        widget.mainListIndex,
                                                        task,
                                                        widget.index,
                                                        index);
                                              },
                                              child: Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Colors.green,
                                                  size: 30),
                                            ),
                                      title: Text(
                                        subtasklist[index].taskTitle,
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    );
                                  }
                                }),
                          ),
                          Divider(
                            thickness: 2,
                          ),
                        ],
                      ),
                      Container(
                        height: 70.0 * urlList.length,
                        child: ListView.builder(
                            itemCount: urlList.length,
                            itemBuilder: (context, index) {
                              // final kb = fileList[index].size / 1024;
                              // final mb = kb / 1024;
                              // final fileSize = mb >= 1
                              //     ? "${mb.toStringAsFixed(2)} MB"
                              //     : "${kb.toStringAsFixed(2)} KB";

                              int start =
                                  urlList[index].toString().indexOf("2F") + 2;
                              int end = urlList[index].toString().indexOf("?");
                              String name = urlList[index]
                                  .toString()
                                  .substring(start, end);

                              return ListTile(
                                title: Text(
                                  name,
                                  style: TextStyle(color: Colors.blue),
                                ),
                                // leading: CircleAvatar(
                                //   backgroundColor: Colors.blue,
                                //   child: Center(
                                //     child: Text(
                                //       fileList[index].extension,
                                //       style: TextStyle(color: Colors.white),
                                //     ),
                                //   ),
                                // ),
                                onTap: () async {
                                  // PDFDocument doc =
                                  //     await PDFDocument.fromURL(urlList[index]);
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             ViewFilePage(doc)));
                                },
                                trailing: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      //fileList.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            }),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                          bottom:
                              BorderSide(width: 1.0, color: Color(0xFF000000)),
                        )),
                        child: ListTile(
                          onTap: () {
                            selectFile();
                          },
                          title: Text(
                            "Attach File",
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                          leading: Icon(Icons.attach_file),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _notesFieldController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (value) {},
                        decoration: const InputDecoration(
                          // prefixIcon: Icon(
                          //   Icons.messenger_outline_outlined,
                          //   color: Colors.grey,
                          // ),
                          // suffixIcon: Icon(
                          //   Icons.more_vert,
                          //   color: Colors.grey,
                          // ),
                          hintText: 'Add notes',
                          border: InputBorder.none,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  selectFile() async {
    final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'jpeg', 'png']);
    final file = res.files.first;
    setState(() {
      fileList.add(file);
      storefile(file);
    });
  }

  Future<void> storefile(PlatformFile file) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    Reference reference =
        firebaseStorage.ref().child("TasksFiles").child(file.name);
    UploadTask uploadTask = reference.putFile(File(file.path));
    uploadTask.snapshotEvents.listen((event) {});

    await uploadTask.whenComplete(() async {
      uploadPath = await uploadTask.snapshot.ref.getDownloadURL();
      //File file = File.fromUri(Uri.file(uploadPath));
      await FirebaseRepo(idUser: widget.userData.uid)
          .uploadFile(widget.mainListIndex, uploadPath, widget.index);
      getSubTask();
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Sub Task'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Task Title"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.red,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Color(0XFF6F8671),
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  setState(() {
                    subTask.add(valueText);
                    subtasklist.add(
                        SubTask(taskTitle: valueText, completionStatus: false));
                    SubTask task =
                        SubTask(completionStatus: false, taskTitle: valueText);
                    FirebaseRepo(idUser: widget.userData.uid).uploadSubTasks(
                        widget.mainListIndex, task, widget.index);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
