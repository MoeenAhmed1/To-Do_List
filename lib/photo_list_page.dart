import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:todo_list/dismissible_widget.dart';
import 'package:todo_list/model/photoitem_model.dart';
import 'package:todo_list/model/task_model.dart';
import 'package:todo_list/model/user_model.dart';
import 'package:todo_list/repo/firebase_repo.dart';
import 'package:todo_list/task_detail.dart';

class PhotoListPage extends StatefulWidget {
  final UserData userData;
  final String title;
  final int index;
  const PhotoListPage({this.userData, this.title, this.index});

  @override
  State<PhotoListPage> createState() => _PhotoListPageState();
}

class _PhotoListPageState extends State<PhotoListPage> {
  String valueText = "";
  bool hideCompletedTask = false;
  bool loading = true;
  PickedFile selectedImage;
  List<PhotoItemModel> photoItemList = [];
  double containerHeight = 360;
  TextEditingController _textFieldController = TextEditingController();

  getPhotos() async {
    setState(() {
      loading = true;
    });
    photoItemList = await FirebaseRepo(idUser: widget.userData.uid)
        .getPhotoItem(widget.index);

    setState(() {
      int check = photoItemList.length % 3;
      int div = photoItemList.length ~/ 3;
      if (check != 0) {
        containerHeight = containerHeight * (div + 1);
      } else {
        containerHeight = containerHeight * div;
      }
      loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhotos();
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
            Icon(Icons.more_vert, size: 30),
            SizedBox(
              width: 10,
            ),
          ],
        ),
        body: Builder(
            builder: (context) => Container(
                constraints: BoxConstraints.expand(),
                // decoration: BoxDecoration(
                //     image: DecorationImage(
                //         image: NetworkImage(
                //             "https://images.pexels.com/photos/1461974/pexels-photo-1461974.jpeg?cs=srgb&dl=pexels-nextvoyage-1461974.jpg&fm=jpg"),
                //         fit: BoxFit.cover)),
                child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: InkWell(
                          onTap: () async {
                            await _displaySelectorDialog(context);
                            if (selectedImage != null) {
                              //_displayTextInputDialog(context);
                              setState(() {
                                loading = true;
                              });
                              await FirebaseRepo(idUser: widget.userData.uid)
                                  .storeImageAndNotes(
                                      File(selectedImage.path), widget.index);
                              setState(() {
                                loading = false;
                              });
                              getPhotos();
                            }
                          },
                          child: Container(
                            color: Color(0XFF6F8671).withOpacity(0.3),
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.grey[700],
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "New Photo",
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 22),
                                    )
                                  ],
                                ),
                                Icon(
                                  Icons.star_border_outlined,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(7.0, 50.0, 7.0, 15.0),
                        child: tasksListWidget(list: photoItemList),
                      ),
                    ],
                  ),
                )))),
      ),
    );
  }

  Future<void> _displaySelectorDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Select'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            final ImagePicker imagePicker = ImagePicker();
                            selectedImage = await imagePicker.getImage(
                                source: ImageSource.camera);
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          icon: Icon(Icons.camera)),
                      Text("Camera"),
                    ],
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                Container(
                  height: 100,
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            final ImagePicker imagePicker = ImagePicker();
                            selectedImage = await imagePicker.getImage(
                                source: ImageSource.gallery);
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          icon: Icon(Icons.photo_album)),
                      Text("Gallery"),
                    ],
                  ),
                ),
              ],
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
              // FlatButton(
              //   color: Color(0XFF6F8671),
              //   textColor: Colors.white,
              //   child: Text('OK'),
              //   onPressed: () {
              //     int i = 0;

              //     setState(() {
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
            ],
          );
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
                    loading = true;
                    //list.removeAt(index);
                  });
                  await FirebaseRepo(idUser: widget.userData.uid)
                      .deleteTask(widget.index, index, isPhotoPage: true);
                  getPhotos();
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<bool> dismissItem(BuildContext context, int index,
      DismissDirection direction, bool isComplete) async {
    if (direction == DismissDirection.endToStart) {
      await _displayConfirmationDialog(
        context,
        index,
      );
      return true;
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

  Widget tasksListWidget(
      {List<PhotoItemModel> list, bool completedTask, Function onpressed}) {
    return InkWell(
      child: Container(
        height: containerHeight,
        //color: Color(0XFF6F8671).withOpacity(0.3),
        child: GridView.builder(
            physics: ScrollPhysics(),
            itemCount: list.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              final item = list[index];
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TaskDetailPage(
                                  userData: widget.userData,
                                  title: 'PhotoDetail',
                                  index: index,
                                  mainListIndex: widget.index,
                                  photoItem: item,
                                  isPhotoPage: true,
                                )));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(item.imgURL),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                color: Colors.grey.withOpacity(0.5),
                                child: IconButton(
                                  icon: (item.completionStatus)
                                      ? Icon(
                                          Icons.check_box,
                                          size: 28,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank,
                                          size: 28,
                                        ),
                                  onPressed: () async {
                                    setState(() {
                                      list[index].completionStatus =
                                          !list[index].completionStatus;
                                      //loading = true;
                                    });
                                    await FirebaseRepo(
                                            idUser: widget.userData.uid)
                                        .updateTask(
                                            list[index].completionStatus,
                                            widget.index,
                                            index,
                                            isPhotoPage: true);
                                    setState(() {
                                      //loading = false;
                                    });
                                  },
                                )),
                            Container(
                                color: Colors.grey.withOpacity(0.5),
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    _displayConfirmationDialog(context, index);
                                  },
                                )),
                          ],
                        ),
                      ],
                    ),
                    // child: Image.network(
                    //   item.imgURL,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),

                // Image.file(
                //   File(imageFileList[index].path),
                //   fit: BoxFit.cover,
                // ),
              );
            }),
        // ListView.separated(
        //     separatorBuilder: (context, index) {
        //       return SizedBox(
        //         width: 20,
        //       );
        //     },
        //     itemCount: list.length,
        //     scrollDirection: Axis.horizontal,
        //     itemBuilder: (context, index) {
        //       final item = list[index];
        //       return Container(
        //         height: 150.0,
        //         width: 250.0,
        //         decoration: BoxDecoration(
        //           image: DecorationImage(
        //             image: NetworkImage(item.imgURL),
        //             fit: BoxFit.cover,
        //           ),
        //           //shape: BoxShape.circle,
        //         ),
        //       );
        //     }),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Notes'),
            content: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Notes (optional)"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Color(0XFF6F8671),
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  Navigator.pop(context);
                  if (valueText.isNotEmpty) {
                    await FirebaseRepo(idUser: widget.userData.uid)
                        .storeImageAndNotes(
                            File(selectedImage.path), widget.index);
                  } else {
                    await FirebaseRepo(idUser: widget.userData.uid)
                        .storeImageAndNotes(
                            File(selectedImage.path), widget.index);
                  }
                  setState(() {
                    loading = false;
                  });
                  getPhotos();
                },
              ),
            ],
          );
        });
  }
}
