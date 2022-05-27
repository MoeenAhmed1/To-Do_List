import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/dismissible_widget.dart';
import 'package:todo_list/model/user_model.dart';
import 'package:todo_list/photo_list_page.dart';
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
  List<String> photoList = [];
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
    photoList = await FirebaseRepo(idUser: userData.uid).getPhotoLists();
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

  Future<void> _displayTextInputDialog(BuildContext context, int index,
      {bool isphotoList, bool isUpdate}) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: (isUpdate) ? Text('Update title') : Text('Add List'),
            content: TextField(
              autofocus: true,
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
                  if (isphotoList == true) {
                    if (valueText.isNotEmpty) {
                      if (isUpdate) {
                        setState(() {
                          photoList.removeAt(index);
                          photoList.insert(index, valueText);
                          //photoList.add(valueText);
                          //taskListLength.add(tasksList.length);
                          _textFieldController.clear();
                          FirebaseRepo(idUser: userData.uid)
                              .updatePhotoList(valueText, index);

                          Navigator.pop(context);
                        });
                      } else {
                        setState(() {
                          _textFieldController.clear();
                          photoList.add(valueText);
                          //taskListLength.add(tasksList.length);

                          FirebaseRepo(idUser: userData.uid)
                              .uploadPhotoList(valueText);

                          Navigator.pop(context);
                        });
                      }
                    }
                  } else {
                    if (valueText.isNotEmpty) {
                      if (isUpdate) {
                        setState(() {
                          tasksList.removeAt(index);
                          tasksList.insert(index, valueText);
                          //tasksList.add(valueText);
                          //taskListLength.add(tasksList.length);

                          FirebaseRepo(idUser: userData.uid)
                              .updateTaskList(valueText, index);
                          _textFieldController.clear();

                          Navigator.pop(context);
                        });
                      } else {
                        setState(() {
                          tasksList.add(valueText);
                          taskListLength.add(tasksList.length);

                          FirebaseRepo(idUser: userData.uid)
                              .uploadTaskList(valueText, index);
                          _textFieldController.clear();

                          Navigator.pop(context);
                        });
                      }
                    }
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
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignOutPage(
                            userName: userName,
                          )));
            },
            child: Center(
              child: CircleAvatar(
                backgroundColor: Color.fromARGB(255, 82, 108, 85),
                radius: 50,
                child: Center(
                  child: (loading)
                      ? Text(
                          '',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        )
                      : Text(
                          userName.substring(0, 1) ?? '',
                          style: TextStyle(fontSize: 22, color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ),
        title: Text(userName ?? ''),
        backgroundColor: Color(0XFF6F8671),
        actions: [
          Icon(Icons.search, size: 30),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      // floatingActionButton: CircleAvatar(
      //   radius: 30.0,
      //   child: IconButton(
      //     onPressed: () async {
      //       await _displayTextInputDialog(context, tasksList.length);
      //     },
      //     icon: Center(
      //       child: Icon(
      //         Icons.add,
      //         size: 35,
      //       ),
      //     ),
      //   ),
      // ),
      body: (loading)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // tileWidget(
                        //     "Inbox",
                        //     Icon(
                        //       Icons.all_inbox_rounded,
                        //       color: Colors.blue,
                        //     ),
                        //     "0"),
                        // tileWidget(
                        //     "Starred",
                        //     Icon(
                        //       Icons.star_border,
                        //       color: Colors.red,
                        //     ),
                        //     "0"),

                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: tileWidget(
                              "Today",
                              Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              "0"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 40,
                          color: Color(0XFF6F8671).withOpacity(0.7),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Tasks List",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                Container(
                                  child: IconButton(
                                    onPressed: () async {
                                      await _displayTextInputDialog(
                                          context, tasksList.length,
                                          isphotoList: false, isUpdate: false);
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 60.0 * (tasksList.length + 1),
                          child: ListView.builder(
                              itemCount: (tasksList.length),
                              // onReorder: (oldIndex, newIndex) => setState(() {
                              //       final index = newIndex > oldIndex
                              //           ? newIndex - 1
                              //           : newIndex;
                              //       print(oldIndex);
                              //       print(index);

                              //       final task = tasksList.removeAt(oldIndex);
                              //       tasksList.insert(index, task);
                              //       // FirebaseRepo(idUser: userData.uid)
                              //       //     .updateTaskListIndex(oldIndex, index);
                              //     }),
                              itemBuilder: (context, index) {
                                // if (index == tasksList.length) {
                                //   return Row(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       Padding(
                                //         padding: const EdgeInsets.all(8.0),
                                //         child: Container(
                                //           width: 50,
                                //           decoration: BoxDecoration(
                                //             borderRadius:
                                //                 BorderRadius.circular(50),
                                //             color: Colors.blue,
                                //             // boxShadow: [
                                //             //   BoxShadow(
                                //             //       color: Colors.blue,
                                //             //       spreadRadius: 3),
                                //             // ],
                                //           ),
                                //           child: IconButton(
                                //             color: Colors.white,
                                //             onPressed: () async {
                                //               await _displayTextInputDialog(
                                //                   context, tasksList.length,
                                //                   isphotoList: false,
                                //                   isUpdate: false);
                                //             },
                                //             icon: Center(
                                //               child: Icon(
                                //                 Icons.add,
                                //                 size: 35,
                                //               ),
                                //             ),
                                //           ),
                                //         ),
                                //       ),
                                //     ],
                                //   );
                                // }

                                final item = tasksList[index];

                                return DismissibleWidget(
                                  key: ValueKey(item),
                                  item: item,
                                  child: Column(
                                    children: [
                                      tileWidget(
                                          tasksList[index],
                                          Icon(
                                            Icons.task,
                                            color: Colors.grey,
                                          ),
                                          '0',
                                          index: index,
                                          isPhotoList: false),
                                      Divider()
                                    ],
                                  ),
                                  confirmDismissed: (direction) async {
                                    dismissItem(context, index, direction);
                                  },
                                );
                              }),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 40,
                          color: Color(0XFF6F8671).withOpacity(0.7),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "Photo List",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 60.0 * (photoList.length + 1),
                          child: ListView.builder(
                              itemCount: (photoList.length) + 1,
                              // onReorder: (oldIndex, newIndex) => setState(() {
                              //       final index = newIndex > oldIndex
                              //           ? newIndex - 1
                              //           : newIndex;
                              //       print(oldIndex);
                              //       print(index);

                              //       final task = tasksList.removeAt(oldIndex);
                              //       tasksList.insert(index, task);
                              //       // FirebaseRepo(idUser: userData.uid)
                              //       //     .updateTaskListIndex(oldIndex, index);
                              //     }),
                              itemBuilder: (context, index) {
                                if (index == photoList.length) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.blue,
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //       color: Colors.blue,
                                            //       spreadRadius: 3),
                                            // ],
                                          ),
                                          child: IconButton(
                                            color: Colors.white,
                                            onPressed: () async {
                                              await _displayTextInputDialog(
                                                  context, photoList.length,
                                                  isphotoList: true,
                                                  isUpdate: false);
                                            },
                                            icon: Center(
                                              child: Icon(
                                                Icons.add,
                                                size: 35,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                final item = photoList[index];

                                return DismissibleWidget(
                                  key: ValueKey(item),
                                  item: item,
                                  child: tileWidget(
                                      photoList[index],
                                      Icon(
                                        Icons.photo,
                                        color: Colors.grey,
                                      ),
                                      '0',
                                      index: index,
                                      isPhotoList: true),
                                  confirmDismissed: (direction) async {
                                    dismissItem(context, index, direction,
                                        isPhotoList: true);
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
      BuildContext context, int index, DismissDirection direction,
      {bool isPhotoList}) async {
    if (direction == DismissDirection.endToStart) {
      await _displayConfirmationDialog(context, index);
      if (isCanceled == false) {
        return true;
      }
      return false;
    }
    if (direction == DismissDirection.startToEnd) {
      await _displayTextInputDialog(context, index,
          isUpdate: true, isphotoList: isPhotoList);
      if (isCanceled == false) {
        return true;
      }
      return false;
    }
    return false;
  }

  Widget tileWidget(String title, Icon icon, String number,
      {int index, bool isPhotoList}) {
    return InkWell(
      onTap: () {
        if (isPhotoList) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PhotoListPage(
                        userData: userData,
                        title: title,
                        index: index,
                      )));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeChoresScreen(
                        userData: userData,
                        title: title,
                        index: index,
                      )));
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 3, 8, 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            //SizedBox(width: 200,),
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: Text(
                number,
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
