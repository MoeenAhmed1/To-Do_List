import 'package:flutter/material.dart';
import 'package:todo_list/task_detail.dart';
class HomeChoresScreen extends StatefulWidget {
  const HomeChoresScreen({Key key}) : super(key: key);

  @override
  _HomeChoresScreenState createState() => _HomeChoresScreenState();
}

class _HomeChoresScreenState extends State<HomeChoresScreen> {
  TextEditingController _textFieldController = TextEditingController();
  List<String> tasks=["Make Dentist Appointment","Prepare birthday party","Call Tom","Meet Erik for lunch","Clean Bathroom"];
  List<String> completedTasks=["Tidy Room"];
  String valueText="";
  bool hideCompletedTask=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: Text("Home Chores"),
        backgroundColor: Color(0XFF6F8671),
        actions: [
          Icon(Icons.person_add_alt,size: 30,),
          SizedBox(width: 25,),
          Icon(Icons.sort_by_alpha_outlined,size: 30),
          SizedBox(width: 25,),
          Icon(Icons.more_vert,size: 30),
          SizedBox(width: 10,),
        ],
      ),
      body: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage("https://images.pexels.com/photos/1461974/pexels-photo-1461974.jpeg?cs=srgb&dl=pexels-nextvoyage-1461974.jpg&fm=jpg"),
                    fit: BoxFit.cover)
            ),
            child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: InkWell(
                          onTap: (){
                            _displayTextInputDialog(context);
                          },
                          child: Container(
                            color: Color(0XFF6F8671).withOpacity(0.3),
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.add,color: Colors.white,size: 30,),
                                    SizedBox(width: 20,),
                                    Text("New to-do",style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22
                                    ),)
                                  ],
                                ),
                                Icon(Icons.star_border_outlined,color: Colors.white,size: 30,),


                              ],
                            ),
                          ),
                        ),
                      ),
                      tasksListWidget(tasksList: tasks,completedTask: false),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: (){
                              setState(() {
                                hideCompletedTask=!hideCompletedTask;
                              });
                            },
                            child: Container(
                              color: Color(0XFF6F8671).withOpacity(0.7),
                              height: 40,
                              width: 150,
                              child: Center(
                                child: Text(
                                  (hideCompletedTask)?"Show Completed Items":"Hide Completed Items",
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      (hideCompletedTask)?Container():tasksListWidget(tasksList: completedTasks,completedTask: true),

                    ],
                  ),
                )
            )
        )

    );
  }
  Widget tasksListWidget({List tasksList,bool completedTask,Function onpressed}){
    return Container(
      height: 65.0*tasksList.length,


      child: ListView.builder(
          itemCount: tasksList.length,
          itemBuilder: (context,index){
            return Padding(
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
                          onPressed: (){
                            if(!completedTask){
                              setState(() {
                                completedTasks.add(tasksList[index]);
                                tasks.removeAt(index);
                              });
                            }
                          },
                          icon: Icon((completedTask)?Icons.check_box:Icons.check_box_outline_blank,color: Colors.grey,size: 30,),
                        ),
                        SizedBox(width: 20,),
                        Text(tasksList[index],style: TextStyle(
                            decoration: (completedTask)?TextDecoration.lineThrough:null,
                            color: Colors.black,
                            fontSize: 18
                        ),)
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star_border_outlined,color: Colors.grey,size: 30,),
                        IconButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  TaskDetailPage()));
                          },
                          icon: Icon(Icons.navigate_next,
                          color: Colors.grey,size: 30,))
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Task'),
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
                onPressed: () {
                  setState(() {
                    tasks.add(valueText);

                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
