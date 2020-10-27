import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../resources/repository.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';

class EditGroup extends StatefulWidget {
  final String groupId;
  final String groupName;
  EditGroup({this.groupId, this.groupName});
  EditGroupState createState() =>
      EditGroupState(groupId: groupId, groupName: groupName);
}

class EditGroupState extends State<EditGroup> {
  final String groupId;
  final String groupName;
  String userNumber;
  bool adminStatus;
  bool changesMade = false;
  Stream<List<UserModel>> _userStream;
  EditGroupState({this.groupId, this.groupName});
  final TextEditingController textEditingController = TextEditingController();

  void initState() {
    super.initState();
    _userStream = context.read<Repository>().getUsersInGroup(groupId);
  }

  void dispose() {
    textEditingController?.dispose();
    super.dispose();
  }

  Widget build(context) {
    var user = context.watch<UserModel>();
    userNumber = user.number;
    adminStatus = user.isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: $groupName'),
      ),
      floatingActionButton: changesMade
          ? FloatingActionButton(
              child: Icon(Icons.done),
              onPressed: () {
                for (UserModel user
                    in Provider.of<GroupModel>(context, listen: false).users) {
                  Provider.of<Repository>(context, listen: false)
                      .updateAdmin(groupId, user.number, user.isAdmin);
                }
                Provider.of<GroupModel>(context, listen: false).clear();
                int count = 0;
                Navigator.of(context).popUntil((_) => count++ >= 2);
                //print('Submit changes');
              })
          : null,
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              (adminStatus)
                  ? ListTile(
                      title: Center(child: Text('Edit chat name')),
                      onTap: () {
                        print('edit name');
                      },
                    )
                  : Container(),

              (adminStatus)
                  ? ListTile(
                      title: Center(child: Text('Add User')),
                      onTap: () {
                        Alert(
                            context: context,
                            title: 'Add a user',
                            content: Container(
                                child: TextField(
                                    controller: textEditingController,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.account_box),
                                      labelText: 'Number',
                                    ))),
                            buttons: [
                              DialogButton(
                                child: Text('Add'),
                                onPressed: () {
                                  print('add: ${textEditingController.text}');
                                  addUser(context, textEditingController.text);
                                  textEditingController.clear();
                                },
                              )
                            ]).show();
                        textEditingController.clear();
                      },
                    )
                  : Container(),

              ListTile(
                title: Center(
                    child: Text(
                  'Exit chat',
                  style: TextStyle(color: Colors.red),
                )),
                onTap: () {
                  print('Exit chat');
                },
              ),
              //buildUser(context, name, number, isAdmin, group)
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('You'),
                trailing: adminStatus ? Text('Admin') : null,
              ),
              // ListView of the users in the group accessed by the provider
              Flexible(
                child: StreamBuilder<List<UserModel>>(
                  stream: _userStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return ListView(children: buildUsers(context));
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> buildUsers(BuildContext context) {
    List<Widget> userList = [];
    GroupModel group = Provider.of<GroupModel>(context, listen: false);
    //GroupModel group = context.watch<GroupModel>();
    for (UserModel user in group.users) {
      print('${user.name}');
      userList.add(buildUser(context, user.name, user.number, user.isAdmin));
    }
    return userList;
  }

// returns the users in the group
  Widget buildUser(
      BuildContext context, String name, String number, bool isAdmin) {
    return (userNumber != number)
        ? ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('$name'),
            trailing: isAdmin ? Text('Admin') : null,
            onTap: () {
              adminStatus
                  ? Alert(
                      context: context,
                      title: name,
                      desc: number,
                      buttons: [
                          DialogButton(
                            child: isAdmin
                                ? Text('remove admin')
                                : Text('make admin'),
                            onPressed: () {
                              setState(() {
                                isAdmin
                                    ? Provider.of<GroupModel>(context,
                                            listen: false)
                                        .makeAdmin(number, false)
                                    : Provider.of<GroupModel>(context,
                                            listen: false)
                                        .makeAdmin(number, true);

                                /*    ? Provider.of<Repository>(context,
                                            listen: false)
                                        .updateAdmin(groupId, number,
                                            false) //group.makeAdmin(number, false)
                                    : Provider.of<Repository>(context,
                                            listen: false)
                                        .updateAdmin(groupId, number,
                                            true);*/ //group.makeAdmin(number, true);
                              });
                              //var rep = Provider.of<Repository>(context, listen: false);
                              //var rep = context.read<Repository>();
                              //setState(() {
                              // Update Firebase and the Provider
                              // TODO - update firebase with the changes made
                              /*if (isAdmin) {
                                if (context != null) {
                                  Provider.of<Repository>(context,
                                          listen: false)
                                      .updateAdmin(groupId, number, false);
                                } else {
                                  print('***********Dunno******');
                                }
                                //rep.updateAdmin(groupId, number, false);
                                //group.makeAdmin(number, false);
                              } else {
                                //rep.updateAdmin(groupId, number, true);
                                if (context != null) {
                                  Provider.of<Repository>(context,
                                          listen: false)
                                      .updateAdmin(groupId, number, true);
                                } else {
                                  print('***********Dunno not admin******');
                                }
                                /*Provider.of<Repository>(context,
                                          listen: false)
                                      .updateAdmin(groupId, number, true);*/
                                //group.makeAdmin(number, true);
                              }*/
                              changesMade = true;
                              /*(isAdmin)
                          ? rep.updateAdmin(groupId, number,
                              false) //group.makeAdmin(number, false)
                          : rep.updateAdmin(groupId, number,
                              true); //group.makeAdmin(number, true);*/
                              //});
                              Navigator.pop(context);
                            },
                          ),
                          DialogButton(
                            child: Text('remove user'),
                            onPressed: () {
                              print('remove user: $name from group');
                            },
                          ),
                        ]).show()
                  : print('Not an admin');
            },
          )
        : Container();
  }

// adds the 'number' to the group
  addUser(BuildContext context, String number) async {
    number = number.trim();
    bool isNumber = false;
    var count = 0;
    UserModel newUser;
    Stream<List<UserModel>> stream =
        Provider.of<Repository>(context, listen: false).getUsers();

    await for (List<UserModel> users in stream) {
      for (UserModel user in users) {
        print('for $number >> user $count: ${user.number}');
        if (user.number == number) {
          isNumber = true;
          newUser = user;
          break;
        }
      }
      if (isNumber) {
        // adds the user to the group
        Provider.of<Repository>(context, listen: false)
            .addUsers(groupId, newUser.number, newUser.name, false);

        // adds the group to the user's list of groups
        Provider.of<Repository>(context, listen: false)
            .addGroup(newUser.number, groupId, groupName);

        changesMade = true;
      }
    }
  }
}
