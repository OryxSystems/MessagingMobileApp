import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class HomeScreen extends StatelessWidget {
  final String name;
  final String number;
  final String _collection1 = 'users';
  final String _collection2 = 'groups';

  HomeScreen({this.name, this.number});

  Widget build(context) {
    // adds the name and number to the provider
    var user = context.watch<UserModel>();
    user.setName(name);
    user.setNumber(number);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
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
            return Text('Loading');
          }
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  buildGroup(context, snapshot.data.documents[index]));
        },
      ),
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
