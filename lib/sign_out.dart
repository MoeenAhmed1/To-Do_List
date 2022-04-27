import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/login_screen.dart';

class SignOutPage extends StatefulWidget {
  const SignOutPage({Key key}) : super(key: key);

  @override
  _SignOutPageState createState() => _SignOutPageState();
}

class _SignOutPageState extends State<SignOutPage> {
  Future<void> _displayConfirmationDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure you want to sign out?'),
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
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false);
                  });
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
        title: Text("Account Details"),
        backgroundColor: Color(0XFF6F8671),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Center(
              child: CircleAvatar(
                backgroundColor: Color(0XFF6F8671).withOpacity(0.5),
                radius: 50,
                child: Center(
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text("Ali", style: TextStyle(fontSize: 30)),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: ListTile(
                title: Text("Sign Out"),
                leading: Icon(Icons.logout_outlined),
                trailing: Icon(Icons.arrow_forward),
                onTap: () async {
                  await _displayConfirmationDialog(context);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
