import 'package:flutter/material.dart';

import 'home_chores_screen.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool workFolderOpen=false;
  bool cookingFolderOpen=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage("https://images.unsplash.com/photo-1541963463532-d68292c34b19?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=688&q=80"),
          ),
        ),
        title: Text("Kate Spencer"),
        backgroundColor: Color(0XFF6F8671),
        actions: [
          Icon(Icons.notifications_outlined,size: 30,),
          SizedBox(width: 25,),
          Icon(Icons.messenger_outline_outlined,size: 30),
          SizedBox(width: 25,),
          Icon(Icons.search,size: 30),
          SizedBox(width: 10,),
        ],
      ),
      floatingActionButton: CircleAvatar(
        radius: 30.0,
        child: Center(
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.add,size: 35,),

          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            children: [
              Column(
                children: [
                  tileWidget("Inbox",Icon(Icons.all_inbox_rounded,color: Colors.blue,),"12"),
                  tileWidget("Starred",Icon(Icons.star_border,color: Colors.red,),"9"),
                  tileWidget("Today",Icon(Icons.calendar_today,color: Colors.green,),"6"),
                  tileWidget("Groceries",Icon(Icons.group,color: Colors.grey,),"8"),
                  tileWidget("Home Chores",Icon(Icons.group,color: Colors.grey,),"5"),
                  tileWidget("Bills",Icon(Icons.list,color: Colors.grey,),"2"),
                  Container(
                    color: (workFolderOpen)?Colors.grey[300]:null,
                    child: dropDownWidget("Work",Icon(Icons.folder_open_outlined,color: Colors.blue,),(){
                      setState(() {
                        workFolderOpen=!workFolderOpen;
                      });
                    },workFolderOpen),
                  ),
                  (workFolderOpen)?Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        tileWidget("Goodin House",Icon(Icons.group,color: Colors.grey,),"11"),
                        tileWidget("Martin's Staircase Renovation",Icon(Icons.group,color: Colors.grey,),"6"),
                        tileWidget("Office Admin",Icon(Icons.group,color: Colors.grey,),"3"),
                      ],
                    ),
                  ):Container(),
                  Container(
                    color: (cookingFolderOpen)?Colors.grey[300]:null,
                    child: dropDownWidget("Cooking",Icon(Icons.folder_open_outlined,color: Colors.blue,),(){
                      setState(() {
                        cookingFolderOpen=!cookingFolderOpen;
                      });
                    },cookingFolderOpen),
                  ),
                  (cookingFolderOpen)?Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        tileWidget("Steak",Icon(Icons.group,color: Colors.grey,),"11"),
                        tileWidget("Burger",Icon(Icons.group,color: Colors.grey,),"6"),
                        tileWidget("Rice",Icon(Icons.group,color: Colors.grey,),"3"),
                      ],
                    ),
                  ):Container(),

                ],
              ),

            ],

          ),
        ),
      ),
    );
  }
  Widget tileWidget(String title,Icon icon,String number)
  {
    return InkWell(
      onTap: (){
        if(title.contains("Home Chores")){
          Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomeChoresScreen()));
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Row(
            children: [
              icon,
              SizedBox(width: 30,),
              Text(title,
                style: TextStyle(
                    fontSize: 18
                ),
              ),
            ],
          ),
          //SizedBox(width: 200,),
          Text(number,
            style: TextStyle(
              color: Colors.grey,
                fontSize: 20
            ),)
        ],),
      ),
    );

  }
  Widget dropDownWidget(String title,Icon icon,Function ontap,bool check)
  {
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
                SizedBox(width: 30,),
                Text(title,
                  style: TextStyle(
                      fontSize: 22
                  ),
                ),
              ],
            ),
            //SizedBox(width: 200,),
            (check)?Icon(Icons.keyboard_arrow_down_sharp,color: Colors.grey,):Icon(Icons.keyboard_arrow_left_outlined,color: Colors.grey,)
          ],),
      ),
    );
  }
}
