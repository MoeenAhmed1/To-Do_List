import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:todo_list/dismissible_widget.dart';
import 'package:todo_list/repo/firebase_repo.dart';
import 'package:todo_list/task_detail.dart';

import 'model/task_model.dart';
import 'model/user_model.dart';

class HomeChoresScreen extends StatefulWidget {
  final UserData userData;
  final String title;
  final int index;
  const HomeChoresScreen({this.userData, this.title, this.index});

  @override
  _HomeChoresScreenState createState() => _HomeChoresScreenState();
}

class _HomeChoresScreenState extends State<HomeChoresScreen> {
  TextEditingController _textFieldController = TextEditingController();
  List<TaskModel> tasks = [];
  List<TaskModel> completedTasks = [];
  List<TaskModel> inCompleteTasks = [];
  String valueText = "";
  bool hideCompletedTask = false;
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTasks();
  }

  getTasks() async {
    completedTasks = [];
    inCompleteTasks = [];
    try {
      tasks = await FirebaseRepo(idUser: widget.userData.uid)
          .getTaskDetails(widget.index);
      for (int i = 0; i < tasks.length; i++) {
        if (tasks[i].completionStatus == true) {
          completedTasks.add(tasks[i]);
        } else {
          inCompleteTasks.add(tasks[i]);
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _displayConfirmationDialog(
      BuildContext context, int index, bool checkCompletedTaskList) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure you want to delete'),
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
                onPressed: () {
                  int i = 0;
                  setState(() {
                    if (checkCompletedTaskList) {
                      i = tasks.indexOf(completedTasks[index]);
                      tasks.remove(completedTasks[index]);
                      completedTasks.removeAt(index);
                    } else {
                      i = tasks.indexOf(inCompleteTasks[index]);
                      tasks.remove(inCompleteTasks[index]);
                      inCompleteTasks.removeAt(index);
                    }

                    FirebaseRepo(idUser: widget.userData.uid)
                        .deleteTask(widget.index, i);
                  });
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: loading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: Color(0XFF6F8671),
            actions: [
              Icon(Icons.sort_by_alpha_outlined, size: 30),
              SizedBox(
                width: 25,
              ),
              Icon(Icons.more_vert, size: 30),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          body: Builder(
              builder: (context) => Container(
                  constraints: BoxConstraints.expand(),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(
                              "https://images.pexels.com/photos/1461974/pexels-photo-1461974.jpeg?cs=srgb&dl=pexels-nextvoyage-1461974.jpg&fm=jpg"),
                          fit: BoxFit.cover)),
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: InkWell(
                            onTap: () {
                              _displayTextInputDialog(context, isUpdate: false);
                            },
                            child: Container(
                              color: Color(0XFF6F8671).withOpacity(0.3),
                              height: 60,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "New to-do",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 22),
                                      )
                                    ],
                                  ),
                                  Icon(
                                    Icons.star_border_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        tasksListWidget(
                            tasksList: inCompleteTasks, completedTask: false),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  hideCompletedTask = !hideCompletedTask;
                                });
                              },
                              child: completedTasks.length == 0
                                  ? Container()
                                  : Container(
                                      color: Color(0XFF6F8671).withOpacity(0.7),
                                      height: 40,
                                      width: 150,
                                      child: Center(
                                        child: Text(
                                          (hideCompletedTask)
                                              ? "Show Completed Items"
                                              : "Hide Completed Items",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (hideCompletedTask)
                            ? Container()
                            : tasksListWidget(
                                tasksList: completedTasks, completedTask: true),
                      ],
                    ),
                  )))),
        ));
  }

  Future<bool> dismissItem(BuildContext context, int index,
      DismissDirection direction, bool isComplete) async {
    if (direction == DismissDirection.endToStart) {
      await _displayConfirmationDialog(context, index, isComplete);
      return true;
    }
    if (direction == DismissDirection.startToEnd) {
      await _displayTextInputDialog(context, index: index, isUpdate: true);
      return true;
    }
    return false;
  }

  Widget tasksListWidget(
      {List<TaskModel> tasksList, bool completedTask, Function onpressed}) {
    return Container(
      height: 65.0 * tasksList.length,
      child: ListView.builder(
          itemCount: tasksList.length,
          itemBuilder: (context, index) {
            final item = tasksList[index];
            return DismissibleWidget(
              item: item,
              confirmDismissed: (direction) {
                dismissItem(context, index, direction, completedTask);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Container(
                  height: 60,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              await FirebaseRepo(idUser: widget.userData.uid)
                                  .updateTask(
                                      !tasksList[index].completionStatus,
                                      widget.index,
                                      index,
                                      taskTitle: tasksList[index].taskTitle,
                                      isPhotoPage: false);
                              getTasks();
                            },
                            icon: Icon(
                              (tasksList[index].completionStatus)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            tasksList[index].taskTitle,
                            style: TextStyle(
                                decoration: (tasksList[index].completionStatus)
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: Colors.black,
                                fontSize: 18),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_border_outlined,
                            color: Colors.grey,
                            size: 30,
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TaskDetailPage(
                                              userData: widget.userData,
                                              title: tasksList[index].taskTitle,
                                              index: index,
                                              mainListIndex: widget.index,
                                              task: tasksList[index],
                                              isPhotoPage: false,
                                            )));
                              },
                              icon: Icon(
                                Icons.navigate_next,
                                color: Colors.grey,
                                size: 30,
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context,
      {int index, bool isUpdate}) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: (isUpdate) ? Text('Update title') : Text('Add Task'),
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
                  if (valueText.isNotEmpty) {
                    if (isUpdate) {
                      setState(() {
                        loading = true;
                      });
                      await FirebaseRepo(idUser: widget.userData.uid)
                          .updateTask(false, widget.index, index,
                              taskTitle: valueText, isPhotoPage: false);
                      setState(() {
                        getTasks();
                        _textFieldController.clear();
                        Navigator.pop(context);
                      });
                    } else {
                      setState(() {
                        FirebaseRepo(idUser: widget.userData.uid)
                            .uploadTaskTitle(valueText, false, widget.index);
                        getTasks();
                        _textFieldController.clear();
                        Navigator.pop(context);
                      });
                    }
                  }
                },
              ),
            ],
          );
        });
  }
}
