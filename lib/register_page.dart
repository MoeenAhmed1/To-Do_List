import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:todo_list/auth_service.dart';
import 'package:todo_list/home_screen.dart';
import 'package:todo_list/login_screen.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool passwordVisible = false;
  bool conPasswordVisible = false;
  String email = "";
  String password = "";
  String name = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Scaffold(
        body:Builder(
          builder: (context) => Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: const DecorationImage(
                  image: const NetworkImage(
                      "https://images.pexels.com/photos/1461974/pexels-photo-1461974.jpeg?cs=srgb&dl=pexels-nextvoyage-1461974.jpg&fm=jpg"),
                  fit: BoxFit.cover),
            ),
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Color(0xFFFFFFFF).withOpacity(0.9),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 90, 50, 20),
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                  "https://images.unsplash.com/photo-1495615080073-6b89c9839ce0?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1206&q=80"),
                              fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        )),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextField(
                                  onChanged: (value) {
                                    name = value;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Name',
                                      border: InputBorder.none),
                                ),
                              ),
                              Divider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextFormField(
                                  onChanged: (val) {
                                    email = val;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Email',
                                      border: InputBorder.none),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Divider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextFormField(
                                  obscureText: !passwordVisible,
                                  onChanged: (value) {
                                    password = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          passwordVisible = !passwordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: TextFormField(
                                  obscureText: !conPasswordVisible,
                                  onChanged: (value) {},
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        // Based on passwordVisible state choose the icon
                                        conPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Update the state i.e. toogle the state of passwordVisible variable
                                        setState(() {
                                          conPasswordVisible =
                                              !conPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                      child: Column(
                        children: [
                          Divider(
                            thickness: 2,
                          ),
                          TextButton(
                              onPressed: () async {
                                final progress = ProgressHUD.of(context);
                                progress.show();
                                final formState = formKey.currentState;
                                if (formState.validate()) {
                                  User user = await AuthService().signUpUser(
                                      email: email, password: password);
                                  progress.dismiss();
                                  if (user != null) {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(
                                                  email: email,
                                                  name: name,
                                                  user: user,
                                                )),
                                        (route) => false);
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => HomePage(
                                    //               email: email,
                                    //               name: name,
                                    //               user: user,
                                    //             )));
                                  }
                                }
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )))));
      
    
  }
}
