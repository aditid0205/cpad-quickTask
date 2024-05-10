import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/register.dart';




class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controllerUsername = TextEditingController();
  final controllerPassword = TextEditingController();
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QuickTask User Authentication",style: TextStyle(color: Color.fromARGB(255, 123, 154, 241))),
        backgroundColor: Color.fromARGB(255, 19, 1, 82),
        centerTitle: true,
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
                enabled: !isLoggedIn,
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
                controller: controllerPassword,
                enabled: !isLoggedIn,
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
                height: 16,
              ),
              Container(
                height: 50,
                child: TextButton(
                  child: const Text('Login'),
                  onPressed: isLoggedIn ? null : () => doUserLogin(),
                   style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Sets the text color
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 2, 30, 83)), // Sets the background color
                    ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                height: 50,
                child: TextButton(
                  child: const Text('Logout'),
                  onPressed: !isLoggedIn ? null : () => doUserLogout(),                   
                ),
              ),
              Container(
                height: 50,
                child: TextButton(
                  child: const Text('Sign-Up'),
                  onPressed: () => doUserRegistration(),
                   
              )
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSuccess(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: Text(message),
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

  void doUserRegistration() async{
    Navigator.pushNamedAndRemoveUntil(
            context, '/register', ModalRoute.withName('/register'));
  } 
  void doUserLogin() async {
   final username = controllerUsername.text.trim();
  final password = controllerPassword.text.trim();

  final user = ParseUser(username, password, null);

var response = await user.login();

if (response.success) {
  showSuccess("User was successfully login!");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("username", username);
  setState(() {
    isLoggedIn = true;
  });
  Navigator.pushNamedAndRemoveUntil(
            context, '/home', ModalRoute.withName('/home'));
} else {
  showError(response.error!.message);
}

  }

  void doUserLogout() async {
  final user = await ParseUser.currentUser() as ParseUser;
  var response = await user.logout();

  if (response.success) {
    showSuccess("User was successfully logout!");
    setState(() {
      isLoggedIn = false;
    });
  } else {
    showError(response.error!.message);
  }
}

}