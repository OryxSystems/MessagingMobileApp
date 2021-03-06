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
        .orderBy('name')
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
    return _firestore
        .collection('users')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((document) =>
              UserModel(document['name'], document['number'], false))
          .toList();
    });
  }

  // adds the group to the users collection
  addGroup(String number, String groupId, String groupName) {
    try {
      var documentReference = _firestore
          .collection('users')
          .doc(number)
          .collection('groups')
          .doc(groupId);

      _firestore.runTransaction((transaction) async {
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
      var documentReference = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('users')
          .doc(number);

      _firestore.runTransaction((transaction) async {
        transaction.set(documentReference,
            {'name': name, 'number': number, 'admin': admin});
      });
    } catch (err) {
      print(err);
    }
  }

  updateAdmin(String groupId, String number, bool admin) {
    try {
      var documentReference = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('users')
          .doc(number);

      _firestore.runTransaction((transaction) async {
        transaction.update(documentReference, {'admin': admin});
      });
    } catch (err) {
      print(err);
    }
  }

  Future<bool> isNumberAdmin(String groupId, String number) async {
    bool b = false;
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('users')
        .doc(number)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        b = documentSnapshot.data()['admin'];
      }
    });
    return b;
  }

  exitGroup(String groupId, String number) {
    deleteGroupFromUser(number, groupId);
    deleteUserFromGroup(groupId, number);
  }

  deleteGroupFromUser(String number, String groupId) {
    try {
      var documentReference = _firestore
          .collection('users')
          .doc(number)
          .collection('groups')
          .doc(groupId);

      _firestore.runTransaction((transaction) async {
        transaction.delete(documentReference);
      });
    } catch (err) {
      print(err);
    }
  }

  deleteUserFromGroup(String groupId, String number) {
    // TODO - if last user then delete group
    try {
      var documentReference = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('users')
          .doc(number);

      _firestore.runTransaction((transaction) async {
        transaction.delete(documentReference);
      });
    } catch (err) {
      print(err);
    }
  }

  Future<String> getNameFromNumber(String number) async {
    String name = '';
    try {
      await _firestore
          .collection('users')
          .doc(number)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          name = documentSnapshot.data()['name'];
          print('name in rep: $name');
          //b = documentSnapshot.data()['admin'];
        }
      });
    } catch (err) {
      print(err);
    }

    return name;
  }
}
