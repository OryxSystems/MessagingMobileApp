import 'package:CommunityHelp/src/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/group_model.dart';
import '../widgets/user_item_group.dart';

class AddGroup extends StatefulWidget {
  AddGroupState createState() => AddGroupState();
}

class AddGroupState extends State<AddGroup> {
  final TextEditingController textEditingController = TextEditingController();

  Widget build(context) {
    return WillPopScope(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.pushNamed(context, '/confirm_group');
          },
        ),
        appBar: AppBar(
          title: Text('Select users'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('Loading...');
            }
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return Builder(
                  builder: (context) {
                    return UserItem(context, snapshot.data.documents[index]);
                  },
                );
              },
            );
          },
        ),
      ),
      onWillPop: () {
        // TODO - ask about?

        var group = context.read<GroupModel>();
        group.clear();
        Navigator.of(context).pop(true);
      },
    );
  }

  void dispose() {
    textEditingController?.dispose();
    super.dispose();
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
                  //onAddGroup(textEditingController.text, context);
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
                onPressed:
                    () {} //onAddGroup(textEditingController.text, context),
                ),
          )
        ],
      ),
    );
  }
}
