import 'package:CommunityHelp/src/models/user_model_group.dart';
import 'package:CommunityHelp/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/user_item_edit.dart';

import '../models/user_model.dart';

class EditGroup extends StatefulWidget {
  final String groupId;
  EditGroup({this.groupId});
  EditGroupState createState() => EditGroupState(groupId: groupId);
}

class EditGroupState extends State<EditGroup> {
  final String groupId;
  String userName;
  Stream<List<UserModelGroup>> _userStream;
  EditGroupState({this.groupId});
  final TextEditingController textEditingController = TextEditingController();

  void initState() {
    super.initState();
    _userStream = context.read<Repository>().getUsersInGroup(groupId);
  }

  Widget build(context) {
    var user = context.watch<UserModel>();
    userName = user.name;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit group'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group_add),
        onPressed: () {
          //addUsers();
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
                child: StreamBuilder<List<UserModelGroup>>(
                  stream: _userStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('Loading...');
                    }
                    return ListView(
                      children: snapshot.data.map(
                        (UserModelGroup user) {
                          return buildUser(context, user.name, user.admin);
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

  Widget buildUser(BuildContext context, String name, bool isAdmin) {
    return ListTile(
      //TODO - change to use number as name might not be unique
      title: (userName == name) ? Text('You') : Text('$name'),
      trailing: isAdmin ? Text('Admin') : null,
      onTap: () {
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

  addUsers() {
    print('add new user');
  }
}
