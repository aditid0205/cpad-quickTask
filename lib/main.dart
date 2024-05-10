import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/homepage.dart';
import 'package:todo_app/register.dart';
import 'package:todo_app/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs;
  final keyApplicationId = 'L6j43JG3ppPWHc1B7VrJjWslORW3HtMnShw59Djk';
  final keyClientKey = 'swden0ZKXMdaWgKGqOhhTDebPwGKIHMJyRnhEBnM';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

    runApp(MaterialApp(
      debugShowCheckedModeBanner: false, 
      initialRoute: '/', 
      routes: 
      {'/': (context) => HomePage (),
        '/home': (context) => Task(),
        '/register' : (context) => Register(),
      }, 

      //home: Home(),

  ));
}
 









































































