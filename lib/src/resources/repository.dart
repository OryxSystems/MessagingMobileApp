import '../models/message_model.dart';
import '../models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Repository {
  Repository(this._firestore);

  final FirebaseFirestore _firestore;

  // used to fetch messages from 'groupId'
  Stream<List<Message>> getMessages(String groupId) {
    print('groupId in repository: $groupId');
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((document) => Message(document['user'], document['content'],
              document['timestamp'], document['image'], document['incident']))
          .toList();
    });
  }

// used to fetch the users belonging to 'groupId'
  Stream<List<UserModel>> getUsersInGroup(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((document) => UserModel(
              document['name'], document['number'], document['admin']))
          .toList();
    });
  }

  // used to fetch all users
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((document) =>
              UserModel(document['name'], document['number'], false))
          .toList();
    });
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
