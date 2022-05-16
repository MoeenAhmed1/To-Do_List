import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/dismissible_widget.dart';
import 'package:todo_list/model/user_model.dart';
import 'package:todo_list/repo/firebase_repo.dart';
import 'package:todo_list/sign_out.dart';

import 'home_chores_screen.dart';

class HomePage extends StatefulWidget {
  final String name;
  final String email;
  final User user;
  const HomePage({this.email, this.name, this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool workFolderOpen = false;
  bool cookingFolderOpen = false;
  UserData userData;
  String userName;
  List<String> tasksList = [];
  String valueText = "";
  TextEditingController _textFieldController = TextEditingController();
  bool loading = true;
  bool isCanceled = false;
  List<int> taskListLength = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.email != null) {
      userData = UserData(
          email: widget.email, name: widget.name, uid: widget.user.uid);
      FirebaseRepo(idUser: widget.user.uid).addUser(userData);
    } else {
      userData = UserData(uid: widget.user.uid);
    }
    getUserName();
  }

  getUserName() async {
    userName = await FirebaseRepo(idUser: userData.uid).getUserName();
    tasksList = await FirebaseRepo(idUser: userData.uid).getTaskLists();
    print(tasksList.length);
    // for (int i = 0; i < tasksList.length; i++) {
    //   final list = await FirebaseRepo(idUser: userData.uid).getTaskDetails(i);
    //   taskListLength.add(list.length);
    // }

    // await FirebaseRepo(idUser: userData.uid).getSubTasks(0, 0);
    setState(() {
      loading = false;
    });
  }

  Future<void> _displayConfirmationDialog(
      BuildContext context, int index) async {
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
                    isCanceled = true;
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Color(0XFF6F8671),
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    tasksList.removeAt(index);
                    FirebaseRepo(idUser: widget.user.uid).deleteTaskList(index);
                  });
                  setState(() {
                    isCanceled = false;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayTextInputDialog(BuildContext context, int index) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add List'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "List Title"),
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
                onPressed: () {
                  if (valueText.isNotEmpty) {
                    setState(() {
                      tasksList.add(valueText);
                      taskListLength.add(tasksList.length);

                      FirebaseRepo(idUser: userData.uid)
                          .uploadTaskList(valueText, index);
                      _textFieldController.clear();

                      Navigator.pop(context);
                    });
                  }
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignOutPage(
                            userName: userName,
                          )));
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=688&q=80"),
            ),
          ),
        ),
        title: Text(userName ?? ''),
        backgroundColor: Color(0XFF6F8671),
        actions: [
          Icon(
            Icons.notifications_outlined,
            size: 30,
          ),
          SizedBox(
            width: 25,
          ),
          Icon(Icons.messenger_outline_outlined, size: 30),
          SizedBox(
            width: 25,
          ),
          Icon(Icons.search, size: 30),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      floatingActionButton: CircleAvatar(
        radius: 30.0,
        child: IconButton(
          onPressed: () async {
            await _displayTextInputDialog(context, tasksList.length);
          },
          icon: Center(
            child: Icon(
              Icons.add,
              size: 35,
            ),
          ),
        ),
      ),
      body: (loading)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        tileWidget(
                            "Inbox",
                            Icon(
                              Icons.all_inbox_rounded,
                              color: Colors.blue,
                            ),
                            "0"),
                        tileWidget(
                            "Starred",
                            Icon(
                              Icons.star_border,
                              color: Colors.red,
                            ),
                            "0"),
                        tileWidget(
                            "Today",
                            Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                            ),
                            "0"),
                        Container(
                          height: 60.0 * tasksList.length,
                          child: ReorderableListView.builder(
                              itemCount: tasksList.length,
                              onReorder: (oldIndex, newIndex) => setState(() {
                                    final index = newIndex > oldIndex
                                        ? newIndex - 1
                                        : newIndex;
                                    print(oldIndex);
                                    print(index);

                                    final task = tasksList.removeAt(oldIndex);
                                    tasksList.insert(index, task);
                                    // FirebaseRepo(idUser: userData.uid)
                                    //     .updateTaskListIndex(oldIndex, index);
                                  }),
                              itemBuilder: (context, index) {
                                final item = tasksList[index];

                                return DismissibleWidget(
                                  key: ValueKey(item),
                                  item: item,
                                  child: tileWidget(
                                      tasksList[index],
                                      Icon(
                                        Icons.task,
                                        color: Colors.grey,
                                      ),
                                      '0',
                                      index: index),
                                  confirmDismissed: (direction) async {
                                    dismissItem(context, index, direction);
                                  },
                                );
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<bool> dismissItem(
    BuildContext context,
    int index,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.endToStart) {
      await _displayConfirmationDialog(context, index);
      if (isCanceled == false) {
        return true;
      }
      return false;
    }
    return false;

    // switch (direction) {
    //   case DismissDirection.endToStart:
    //     Utils.showSnackBar(context, 'Chat has been deleted');
    //     break;
    //   case DismissDirection.startToEnd:
    //     Utils.showSnackBar(context, 'Chat has been archived');
    //     break;
    //   default:
    //     break;
    // }
  }

  Widget tileWidget(String title, Icon icon, String number, {int index}) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeChoresScreen(
                      userData: userData,
                      title: title,
                      index: index,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                SizedBox(
                  width: 30,
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            //SizedBox(width: 200,),
            Text(
              number,
              style: TextStyle(color: Colors.grey, fontSize: 20),
            )
          ],
        ),
      ),
    );
  }

  Widget dropDownWidget(String title, Icon icon, Function ontap, bool check) {
    return InkWell(
      onTap: ontap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                SizedBox(
                  width: 30,
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 22),
                ),
              ],
            ),
            //SizedBox(width: 200,),
            (check)
                ? Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: Colors.grey,
                  )
                : Icon(
                    Icons.keyboard_arrow_left_outlined,
                    color: Colors.grey,
                  )
          ],
        ),
      ),
    );
  }
}
