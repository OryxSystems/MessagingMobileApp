import 'package:CommunityHelp/src/models/message_model.dart';
import 'package:CommunityHelp/src/screens/add_group.dart';
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
          .map((document) => Message(
              document['user'], document['content'], document['timestamp']))
          .toList();
    });
  }
}
