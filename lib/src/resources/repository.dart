import '../models/message_model.dart';
import '../models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Repository {
  Repository(this._firestore);

  final FirebaseFirestore _firestore;

  // used to fetch messages from 'groupId'
  Stream<List<Message>> getMessages(String groupId) {
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
}
