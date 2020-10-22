import 'dart:async';

import 'package:CommunityHelp/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../resources/repository.dart';

import '../models/user_model.dart';

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
  Stream<List<UserModel>> _userStream;
  EditGroupState({this.groupId, this.groupName});
  final TextEditingController textEditingController = TextEditingController();

  void initState() {
    super.initState();
    _userStream = context.read<Repository>().getUsersInGroup(groupId);
  }

  Widget build(context) {
    var user = context.watch<UserModel>();
    userNumber = user.number;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit group'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group_add),
        onPressed: () {
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
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Flexible(
                child: StreamBuilder<List<UserModel>>(
                  stream: _userStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('Loading...');
                    }
                    return ListView(
                      children: snapshot.data.map(
                        (UserModel user) {
                          return buildUser(
                              context, user.name, user.number, user.isAdmin);
                        },
                      ).toList(),
                    );
                  },
                ),
              ),
              //buildInput()
            ],
          )
        ],
      ),
    );
  }

  Widget buildUser(
      BuildContext context, String name, String number, bool isAdmin) {
    return ListTile(
      //TODO - change to use number as name might not be unique
      title: (userNumber == number) ? Text('You') : Text('$name'),
      trailing: isAdmin ? Text('Admin') : null,
      onTap: () {
        print('this is the group name: $groupName');
        print('number: $number');
        Alert(context: context, title: name, buttons: [
          DialogButton(
            child: Text('make admin'),
            onPressed: () {
              print('make user: $name an admin');
            },
          ),
          DialogButton(
            child: Text('remove user'),
            onPressed: () {
              print('remove user: $name from group');
            },
          ),
        ]).show();
      },
    );
  }

  addUser(BuildContext context, String number) async {
    /*var transformer = new StreamTransformer.fromHandlers(
        handleData: (List<UserModel> users, sink) {
      for (UserModel user in users) {
        if (user.number == number) {
          isNumber = true;
          break;
        }
      }
    });*/
    number = number.trim();
    bool isNumber = false;
    var count = 0;
    UserModel newUser;
    //Provider.of(context);
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
        Provider.of<Repository>(context, listen: false)
            .addUsers(groupId, newUser.number, newUser.name, false);

        Provider.of<Repository>(context, listen: false)
            .addGroup(newUser.number, groupId, groupName);
      }
    }

/*
    if (isNumber){

    }*/
  }
}
