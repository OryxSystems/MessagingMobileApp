import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  Widget build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select User'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  buildItem(context, snapshot.data.documents[index]),
            );
          },
        ));
  }

  // An item being the users which can be selected as the current user
  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      trailing: Icon(Icons.keyboard_arrow_right),
      title: Text(document['name']),
      onTap: () {
        Navigator.pushNamed(
            context, '/home{${document['name']}: ${document['number']}}');
      },
    );
  }
}
