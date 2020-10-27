import 'package:CommunityHelp/src/models/group_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../resources/load_image.dart';
import '../resources/load_video.dart';
import '../screens/play_video.dart';
import '../models/message_model.dart';
import '../resources/repository.dart';
import '../models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  ChatScreen({this.groupId, this.groupName});

  ChatScreenState createState() =>
      ChatScreenState(groupId: groupId, groupName: groupName);
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final ImagePicker picker = ImagePicker();
  //final String user;
  String userName;
  String userNumber;
  final String groupId;
  final String groupName;
  final String messages = 'messages';
  Stream<List<Message>> _messageStream;
  Stream<List<UserModel>> _usersInGroupStream;

  void initState() {
    super.initState();
    _messageStream = context.read<Repository>().getMessages(groupId);
    _usersInGroupStream = context.read<Repository>().getUsersInGroup(groupId);
    var user = Provider.of<UserModel>(context, listen: false);
    addUsersToProvider(context);
    userName = user.name;
    userNumber = user.number;
    print('groupId in initStae: $groupId');
  }
/*
  void dispose() {
    textEditingController?.dispose();
    listScrollController?.dispose();
    super.dispose();
  }*/

  ChatScreenState({this.groupId, this.groupName});

  Widget build(context) {
    return WillPopScope(
        onWillPop: () {
          // TODO - ask about?

          var group = context.read<GroupModel>();
          group.clear();
          var user = Provider.of<UserModel>(context, listen: false);
          user.setAdmin(false);
          Navigator.of(context).pop(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () {
                print('content: /edit_group{$groupId: $groupName}');
                Navigator.pushNamed(
                    context, '/edit_group{$groupId: $groupName}');
              },
              child: Text('$groupName'),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/report_incident{$groupId}');
                  },
                  child: Icon(Icons.report),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                        context, '/edit_group{$groupId: $groupName}');
                  },
                  child: Icon(Icons.edit),
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
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListView(
                          reverse: true,
                          children: snapshot.data.map(
                            (Message message) {
                              return buildMessage(
                                  context,
                                  message.user,
                                  message.content,
                                  message.date,
                                  message.image,
                                  message.incident);
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
        ));
  }

  // each individual message
  Widget buildMessage(BuildContext context, String number, String content,
      Timestamp date, String image, String incident) {
    //TODO - change the time for different timezones
    String newDate = '';
    // before if minutes started with 0, 0 wouldn't be included
    if ('${date.toDate().minute}'.length < 2) {
      newDate = '0${date.toDate().minute}';
    } else {
      newDate = '${date.toDate().minute}';
    }

    var group = Provider.of<GroupModel>(context, listen: false);
    String name = group.getNameFromNumber(number);

    if ('$incident' == 'none') {
      return Container(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Column(
            crossAxisAlignment: (number != userNumber)
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
                      color: (number != userNumber)
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
                    '${date.toDate().hour}: $newDate',
                    style: TextStyle(color: Colors.grey),
                  ))
            ],
          ));
    } else {
      return buildIncident(name, content, date, image, incident, newDate);
    }
  }

  buildIncident(String name, String content, Timestamp date, String image,
      String incident, String newDate) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(right: 10.0),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              '$name',
              style: TextStyle(color: Colors.black),
            )),
        ListTile(
          title: Text('Incident: $incident'),
          subtitle: Text(content),
          trailing: Icon(Icons.report),
          onTap: () async {
            bool isVid = false;
            String vidUrl;
            try {
              if (image.endsWith('.mp4')) {
                //image = 'none';
                isVid = true;
                vidUrl = await loadVideo(context, 'videos/$image');
              }
              Alert(
                      context: context,
                      title: 'Icident: $incident',
                      desc: 'Description: $content',
                      buttons: isVid
                          ? [
                              DialogButton(
                                child: Text('Play Video'),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PlayVideo(
                                                vidUrl: vidUrl,
                                              )));
                                  //Navigator.pop(context);
                                },
                              )
                            ]
                          : null,
                      image: (image != 'none' && !isVid)
                          ? await loadImage(context, 'uploads/$image')
                          : null)
                  .show();
            } catch (err) {
              print(err);
            }
          },
        ),
        Container(
            margin: EdgeInsets.only(right: 10.0),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              '${date.toDate().hour}: $newDate',
              style: TextStyle(color: Colors.grey),
            ))
      ],
    );
  }
/*
  Future<Widget> getImage(BuildContext context, String image) async {
    Image m;
    await FirebaseStorage.instance
        .ref()
        .child(image)
        .getDownloadURL()
        .then((downloadUrl) {
      m = Image.network(
        downloadUrl.toString(),
        fit: BoxFit.scaleDown,
      );
    });
    return m;
  }*/

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
                decoration: InputDecoration(hintText: 'Enter message'),
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
        transaction.set(documentReference, {
          'content': content,
          'image': 'none',
          'incident': 'none',
          'timestamp': Timestamp.now(),
          'user': userNumber,
        });
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

  addUsersToProvider(BuildContext context) async {
    var group = Provider.of<GroupModel>(context, listen: false);
    await for (List<UserModel> users in _usersInGroupStream) {
      for (UserModel user in users) {
        if (user.number == userNumber) {
          user.setName('You');
          Provider.of<UserModel>(context, listen: false).setAdmin(user.isAdmin);
        }
        group.add(user);
      }
    }
  }
}
