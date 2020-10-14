import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/group_model.dart';
import '../models/user_model.dart';

class UserItem extends StatelessWidget {
  final BuildContext bcontext;
  final DocumentSnapshot document;
  UserItem(this.bcontext, this.document);

  Widget build(BuildContext context) {
    UserModel user = UserModel(document['name'], document['number']);
    // TODO - dont display if logged in user
    bool isAdded =
        context.select<GroupModel, bool>((group) => group.users.contains(user));
    return Container(
      color: isAdded ? Colors.blue[100] : null,
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: Consumer<GroupModel>(
        builder: (context, group, child) => ListTile(
          trailing: isAdded ? Icon(Icons.check_circle) : Icon(Icons.add),
          title: Text(document['name']),
          onTap: isAdded
              ? () {
                  var group = context.read<GroupModel>();
                  group.remove(user);
                }
              : () {
                  var group = context.read<GroupModel>();
                  group.add(user);
                },
        ),
      ),
    );
  }
}
