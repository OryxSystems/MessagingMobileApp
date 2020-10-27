import 'package:CommunityHelp/src/models/group_model.dart';
import 'package:CommunityHelp/src/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../models/group_model.dart';

class ConfirmGroup extends StatefulWidget {
  ConfirmGroupState createState() => ConfirmGroupState();
}

class ConfirmGroupState extends State<ConfirmGroup> {
  final TextEditingController textEditingController = TextEditingController();
  Widget build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New group'),
        ),
        body: buildInput());
  }

  Widget buildInput() {
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: TextField(
                onSubmitted: (value) {
                  onAddGroup(textEditingController.text, context);
                },
                controller: textEditingController,
                decoration: InputDecoration(hintText: 'Enter group name'),
                textInputAction: TextInputAction.send,
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => onAddGroup(textEditingController.text, context),
            ),
          )
        ],
      ),
    );
  }

  // adds the input data to the firebase firestore
  onAddGroup(String groupName, BuildContext context) {
    String groupId = Uuid().v4();
    GroupModel group = context.read<GroupModel>();

    try {
      //adds the groupName to the groups/groupid collection
      var documentReference =
          FirebaseFirestore.instance.collection('groups').doc(groupId);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(documentReference, {'groupName': groupName});
      });
    } catch (err) {
      print(err);
    }
    //TODO - use repository more
    for (UserModel user in group.users) {
      addUsers(groupId, user.number, user.name, false);
    }
    var selectedUser = context.read<UserModel>();
    // Adds the logged in user
    addUsers(groupId, selectedUser.number, selectedUser.name, true);
    addGroup(selectedUser.number, groupId, groupName);

    for (UserModel user in group.users) {
      addGroup(user.number, groupId, groupName);
    }

    group.clear();
    // goes back two screens
    //TODO - might need to change to use Navigate.withname
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
    /*Navigator.popUntil(
        context, ModalRoute.withName('/h{${user.name}: ${user.number}}'));*/
  }

  // adds the group to the users collection
  addGroup(String number, String groupId, String groupName) {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('users')
          .doc(number)
          .collection('groups')
          .doc(groupName);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
            documentReference, {'groupId': groupId, 'groupName': groupName});
      });
    } catch (err) {
      print(err);
    }
  }

  // adds the users to the group/groupid/users collection
  addUsers(String groupId, String number, String name, bool admin) {
    try {
      var documentReference = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('users')
          .doc(number);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(documentReference,
            {'name': name, 'number': number, 'admin': admin});
      });
    } catch (err) {
      print(err);
    }
  }
}
