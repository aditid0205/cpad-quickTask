import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/homepage.dart';
import 'package:todo_app/register.dart';


class Task extends StatefulWidget {
  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  final todoController = TextEditingController();
  final descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void addToDo() async {
    if (todoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please Provide A Task Name"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red
      ));
       return;
    } 
    await saveTodo(todoController.text, descriptionController.text);
    setState(() {
      todoController.clear();
      descriptionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 251, 252),
      appBar: AppBar(
        title: Text("QuickTask",style: TextStyle(color: Color.fromARGB(255, 123, 154, 241))),
        backgroundColor: Color.fromARGB(255, 19, 1, 82),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Color.fromARGB(255, 59, 167, 255),
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child:
              TextField(
                autocorrect: true,
                textCapitalization: TextCapitalization.sentences,
                controller: todoController,
                decoration: InputDecoration(
                    labelText: "Add A New Task",
                    labelStyle: TextStyle(color: Colors.black)),
              )),
          
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child:
              ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 2, 30, 83),
              ),
              onPressed: addToDo,
              child: Text("+")
            )),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTodo(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator()),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return Scrollbar(
                            controller: _scrollController,
                            child: ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              controller: _scrollController,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTodo = snapshot.data![index];
                                String varTitle = varTodo.get<String>('title')!;
	                              String varDescription = varTodo.get<String>('description')!;
                                final varDone =  varTodo.get<bool>('done')!;
                                //*************************************

                                return ListTile(
                                  title: Text(varTitle),
                                  subtitle: Text(varDescription),
                                  leading: CircleAvatar(
                                    child: Icon(
                                        varDone ? Icons.check : Icons.assignment),
                                    backgroundColor:
                                        varDone ? Color.fromARGB(255, 12, 1, 63) : Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                      onPressed: varDone ? null : () async {
                                        // Copy title and description to the TextFields
                                        todoController.text = varTitle;
                                        descriptionController.text = varDescription;
                                        await deleteTodo(varTodo.objectId!);
                                        setState(() {
                                          final snackBar = SnackBar(
                                            content: Text("Todo being edited!"),
                                            duration: Duration(seconds: 2),
                                          );
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(snackBar);
                                        });
                                      },
                                      ),
                                      Checkbox(
                                          value: varDone,
                                          onChanged: (value) async {
                                            await updateTodo(
                                                varTodo.objectId!, value!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Color.fromARGB(255, 145, 4, 4),
                                        ),
                                        onPressed: () async {
                                          await deleteTodo(varTodo.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text("Task deleted!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }));
                        }
                    }
                  })),
                  Container(
                  height: 50,
                  child: TextButton(
                    child: const Text('Logout'),
                    onPressed: () => doUserLogout(),
                    style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Sets the text color
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 2, 30, 83)), // Sets the background color
  ),
                ),
              ),
        ]
      ),
      
    );
  }

  Future<void> saveTodo(String title, String description) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      print("user name>>>"); 
      print(username);
    final todo = ParseObject('ToDoList')..set('title', title)..set('description', description)..set('username',username)..set('done', false);
    await todo.save();
  }

  Future<List<ParseObject>> getTodo() async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      print("user name>>>"); 
      print(username);

     QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('ToDoList'));
        queryTodo.whereEqualTo("username", username);
        queryTodo.orderByAscending('done');
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      print("results");
      print(apiResponse.results);
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTodo(String id, bool done) async {
  var todo = ParseObject('ToDoList')
    ..objectId = id
    ..set('done', done);
  await todo.save();
  }

  Future<void> deleteTodo(String id) async {
  var todo = ParseObject('ToDoList')..objectId = id;
  await todo.delete();
  }

  Future<void> editTodo(String id, String title, String description) async {
  final todo = ParseObject('ToDoList')..objectId = id ..set('title', title)..set('description', description);
  await todo.save();
  }
  
  void doUserLogout() async {
  final user = await ParseUser.currentUser() as ParseUser;
  var response = await user.logout();

  if (response.success) {
    showSuccess("User was successfully logout!");
    Navigator.pushNamedAndRemoveUntil(
            context, '/', ModalRoute.withName('/'));
  } else {
    showError(response.error!.message);
  }
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
}