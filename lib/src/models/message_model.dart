import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  Message(this.user, this.content, this.date);
  final String user;
  final String content;
  final Timestamp date;
}
