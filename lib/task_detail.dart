import 'package:flutter/material.dart';
class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({Key key}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  List<String> subTask=["Call Dr. Thomas","Health insurance card","X-Ray images"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Center(
          child: Text("Make Dentist Appointment",style: TextStyle(
            color: Colors.black
          ),),
        ),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.star_border,color: Colors.grey,),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage("https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=688&q=80"),
                      ),
                      SizedBox(width: 20,),
                      Text("Andrew Spencer",style: TextStyle(
                        fontSize: 22
                      ),),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Divider(thickness: 2,),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,color: Colors.blue,),
                      SizedBox(width: 20,),
                      Text("Due Today",style: TextStyle(
                          fontSize: 22,
                        color: Colors.blue
                      ),),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [

                      Icon(Icons.notifications_outlined,color: Colors.blue,),
                      SizedBox(width: 20,),
                      Text("Remind me at 10 AM",style: TextStyle(
                          fontSize: 22,
                          color: Colors.blue
                      ),),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Icon(Icons.access_time,color: Colors.grey,),
                      SizedBox(width: 20,),
                      Text("Never Repeat",style: TextStyle(
                          fontSize: 22,
                          color: Colors.grey
                      ),),
                    ],
                  ),
                  SizedBox(height: 20,),
                  Divider(thickness: 2,),
                  Container(
                    height: 60.0*(subTask.length+1),

                    child: ListView.builder(
                      itemCount: subTask.length+1,
                        itemBuilder: (context,index){

                        if(index==subTask.length){

                          return ListTile(
                            leading: Icon(Icons.add,color: Colors.grey,size: 30,),
                            title: Text("Add a Subtask",style: TextStyle(
                                fontSize: 22,
                              color: Colors.grey
                            ),),
                          );
                        }
                        else{
                          return ListTile(
                            leading: Icon(Icons.check_box_outline_blank,color: Colors.green,size: 30),
                            title: Text(subTask[index],style: TextStyle(
                                fontSize: 22
                            ),),
                          );
                        }

                        }
                    ),
                  ),


                  Divider(thickness: 2,),

                ],
              ),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.messenger_outline_outlined,color: Colors.grey,),
                  suffixIcon: Icon(Icons.more_vert,color: Colors.grey,),
                  hintText: 'Add a comment',
                  border: InputBorder.none,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
