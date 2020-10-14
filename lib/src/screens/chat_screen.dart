import 'package:CommunityHelp/src/models/message_model.dart';
import 'package:CommunityHelp/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final String user;
  final String groupId;
  ChatScreen({this.user, this.groupId});

  ChatScreenState createState() =>
      ChatScreenState(user: user, groupId: groupId);
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final ImagePicker picker = ImagePicker();
  final String user;
  final String groupId;
  final String messages = 'messages';
  Stream<List<Message>> _messageStream;

  void initState() {
    super.initState();
    _messageStream = context.read<Repository>().getMessages(groupId);
  }

  ChatScreenState({this.user, this.groupId});

  Widget build(context) {
    var user = context.watch<UserModel>();
    print('nameOnchat: ${user.name}; number ${user.number}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.more_vert),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Flexible(
                child: StreamBuilder<List<Message>>(
                  stream: _messageStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text('Loading...');
                    }
                    return ListView(
                      reverse: true,
                      children: snapshot.data.map(
                        (Message message) {
                          return buildMessage(context, message.user,
                              message.content, message.date);
                        },
                      ).toList(),
                    );
                  },
                ),
              ),
              buildInput()
            ],
          )
        ],
      ),
    );
  }

  // each individual message
  Widget buildMessage(
      BuildContext context, String name, String content, Timestamp date) {
    //TODO - change the time for different timezones
    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: Column(
          crossAxisAlignment: (name != user)
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Container(
                width: 200.0,
                padding: EdgeInsets.only(bottom: 10.0),
                margin: EdgeInsets.only(left: 10.0),
                child: Text(
                  '$name',
                  style: TextStyle(color: Colors.black),
                )),
            Container(
                decoration: BoxDecoration(
                    color: (name != user)
                        ? Colors.blueGrey[800]
                        : Colors.blue[700],
                    borderRadius: BorderRadius.circular(8.0)),
                padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                width: 200.0,
                margin: EdgeInsets.only(left: 10.0),
                child: Text(
                  '$content',
                  style: TextStyle(color: Colors.white),
                )),
            Container(
                padding: EdgeInsets.only(top: 10.0),
                width: 200.0,
                margin: EdgeInsets.only(left: 10.0),
                child: Text(
                  '${date.toDate().hour}: ${date.toDate().minute}',
                  style: TextStyle(color: Colors.grey),
                ))
          ],
        ));
  }

  // the input text field who's input data is a new message
  Widget buildInput() {
    return Container(
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5))),
      child: Row(
        children: [
          /*Container(
              child: IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              getCameraImage();
            },
          )),
          Container(
              child: IconButton(
            icon: Icon(Icons.photo),
            onPressed: () {
              getGalleryImage();
            },
          )),*/
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text);
                },
                controller: textEditingController,
                decoration: InputDecoration(),
                textInputAction: TextInputAction.send,
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => onSendMessage(textEditingController.text),
            ),
          )
        ],
      ),
    );
  }

  // Sends the input data(content) to the firebase firestore
  onSendMessage(String content) {
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection(messages)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(documentReference,
            {'content': content, 'timestamp': Timestamp.now(), 'user': user});
      });
    }
  }

  //not used currently
  Future getCameraImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {}
    });
  }

// not used currently
  Future getGalleryImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {}
    });
  }
}
