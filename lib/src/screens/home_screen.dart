import 'package:CommunityHelp/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String name;
  String number;
  final String _collection1 = 'users';
  final String _collection2 = 'groups';
  TextEditingController usernameController = new TextEditingController();
  TextEditingController usernumberController = new TextEditingController();

  //HomeScreen({this.name, this.number});

  Future<bool> checkPrefs(BuildContext context, bool newLogin) async {
    bool loggedIn = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uname = prefs.getString('name');
    String unumber = prefs.getString('number');
    var user = context.read<UserModel>();
    if (unumber != null && !newLogin) {
      print(unumber);
      name = uname;
      number = unumber;
      user.setName(uname);
      user.setNumber(unumber);
      loggedIn = true;
    } else {
      Alert(
          context: context,
          title: newLogin ? 'Change account' : 'Login',
          content: Column(children: <Widget>[
            /*TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'User name'),
            ),*/
            TextField(
              controller: usernumberController,
              decoration: InputDecoration(labelText: 'User number'),
            )
          ]),
          buttons: [
            DialogButton(
              child: Text('Login'),
              onPressed: () async {
                // TODO - better check
                String n = await context
                    .read<Repository>()
                    .getNameFromNumber(usernumberController.text);
                print('name: $n');
                if (n != '' && usernumberController.text != null) {
                  user.setName(n);
                  user.setNumber(usernumberController.text);
                  prefs.setString('name', n);
                  prefs.setString('number', usernumberController.text);
                  loggedIn = true;
                } else {
                  print('Wrong number');
                }
                setState(() {
                  usernameController.clear();
                  usernumberController.clear();
                  Navigator.pop(context);
                });
              },
            ),
            DialogButton(
              child: Text('Logout'),
              onPressed: () {
                prefs.setString('name', null);
                prefs.setString('number', null);
                user.setName(null);
                user.setNumber(null);
                setState(() {
                  usernameController.clear();
                  usernumberController.clear();
                  Navigator.pop(context);
                });
              },
            )
          ]).show();
      //prefs.setString('userName', 'Barry');
      //print('not logged in');
    }
    return loggedIn;
  }

  loginScreen() {}

  Widget build(context) {
    // adds the name and number to the provider
    /*var user = context.watch<UserModel>();
    user.setName(name);
    user.setNumber(number);*/
    //bool b = await checkPrefs();
    return FutureBuilder(
      future: checkPrefs(context, false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.data) {
            return Scaffold(
                body: Center(
              child: RaisedButton(
                child: Text('Login'),
                onPressed: () {
                  checkPrefs(context, true);
                },
              ),
            ));
          } else {
            return Scaffold(
              appBar: AppBar(title: Text('Chats'), actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      checkPrefs(context, true);
                      //Navigator.pushNamed(context, '/report_incident{$groupId}');
                    },
                    child: Icon(Icons.account_circle),
                  ),
                ),
              ]),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.group_add),
                onPressed: () {
                  Navigator.pushNamed(context, '/add_group');
                },
              ),
              body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(_collection1)
                    .doc(number)
                    .collection(_collection2)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) =>
                          buildGroup(context, snapshot.data.documents[index]));
                },
              ),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  // the groups which the member belongs to
  Widget buildGroup(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      trailing: Icon(Icons.keyboard_arrow_right),
      title: Text(document['groupName']),
      onTap: () {
        Navigator.pushNamed(
            context, '/chat{${document['groupId']}: ${document['groupName']}}');
      },
    );
  }
}
