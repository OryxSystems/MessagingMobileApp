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
  Widget build(context) {
    return WillPopScope(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
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
}
