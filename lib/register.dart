
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget{

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<Register>{

  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerEmail = TextEditingController();

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('QuickTask User registration'),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [             
            SizedBox(
              height: 16,
            ),
             
            SizedBox(
              height: 16,
            ),
            TextField(
              controller: controllerUsername,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  labelText: 'Username'),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: controllerEmail,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  labelText: 'E-mail'),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: controllerPassword,
              obscureText: true,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  labelText: 'Password'),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              height: 50,
              child: TextButton(
                child: const Text('Sign Up'),
                onPressed: () => doUserRegistration(),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

void showSuccess() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Success!"),
        content: const Text("User was successfully created!"),
        actions: <Widget>[
          new TextButton(
            child: const Text("OK"),
            onPressed: () {
              
              Navigator.pushNamedAndRemoveUntil(
             context, '/home', ModalRoute.withName('/home'));

            },
          ),
        ],
      );
    },
  );
}

void showError(String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Error!"),
        content: Text(errorMessage),
        actions: <Widget>[
          new TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              
            },
          ),
        ],
      );
    },
  );
}

 
  void doUserRegistration() async {
    
  final username = controllerUsername.text.trim();
  final email = controllerEmail.text.trim();
  final password = controllerPassword.text.trim();

  final user = ParseUser.createUser(username, password, email);

  var response = await user.signUp();

  if (response.success) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    showSuccess();
  } else {
    showError(response.error!.message);
  }
}

}