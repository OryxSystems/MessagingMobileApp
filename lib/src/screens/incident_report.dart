import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:video_player/video_player.dart';

import '../widgets/upload_image.dart';
import '../models/user_model.dart';

class NewReport extends StatefulWidget {
  final String groupId;
  NewReport({this.groupId});
  NewReportState createState() => NewReportState(groupId: groupId);
}

class NewReportState extends State<NewReport> {
  final TextEditingController textEditingController = TextEditingController();
  VideoPlayerController videoPlayerController;
  final ImagePicker picker = ImagePicker();
  final String groupId;
  File imageFile;
  String fileName;
  String selectedIncident = '1';
  String userNumber;

  NewReportState({this.groupId});

  Widget build(context) {
    var user = context.watch<UserModel>();
    userNumber = user.number;
    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Report'),
      ),
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Center(
            child: Container(
              child: DropdownButton<String>(
                style: TextStyle(fontSize: 20.0, color: Colors.black),
                value: selectedIncident,
                hint: Text('Select an incident'),
                items: [
                  DropdownMenuItem(
                    child: Text('First incident'),
                    value: '1',
                  ),
                  DropdownMenuItem(
                    child: Text('Second incident'),
                    value: '2',
                  ),
                  DropdownMenuItem(
                    child: Text('Third incident'),
                    value: '3',
                  )
                ],
                onChanged: (String value) {
                  setState(() {
                    selectedIncident = value;
                  });
                },
              ),
            ),
          ),
          Center(
            child: (videoPlayerController != null)
                ? videoPlayerController.value.initialized
                    ? AspectRatio(
                        aspectRatio: videoPlayerController.value.aspectRatio,
                        child: Stack(children: <Widget>[
                          VideoPlayer(videoPlayerController),
                          Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                child: videoPlayerController.value.isPlaying
                                    ? Icon(Icons.pause)
                                    : Icon(Icons.play_arrow),
                                onTap: () {
                                  setState(() {
                                    (videoPlayerController.value.isPlaying)
                                        //? print('pause')
                                        //: print('play');
                                        ? videoPlayerController.pause()
                                        : videoPlayerController.play();
                                  });
                                },
                              )),
                        ]),
                      )
                    : Container(
                        child: CircularProgressIndicator(),
                      )
                : Text('not loaded'),
          ),
          /*Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
              child: (imageFile != null && !fileName.endsWith('.mp4'))
                  ? Stack(children: <Widget>[
                      Image.file(imageFile),
                      Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            child: Icon(Icons.close),
                            onTap: () {
                              setState(() {
                                imageFile = null;
                                //fileName = null;
                              });
                            },
                          )),
                    ])
                  : Text(
                      'No image selected',
                      textAlign: TextAlign.center,
                    ),
            ),
          ),*/
          buildInput(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 40.0,
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  Alert(
                      context: context,
                      title: 'Select camera or gallery for image',
                      buttons: [
                        DialogButton(
                          child: Text('Camera'),
                          onPressed: () {
                            getCameraImage(context);
                            Navigator.pop(context);
                          },
                        ),
                        DialogButton(
                          child: Text('Gallery'),
                          onPressed: () {
                            getGalleryImage(context);
                            Navigator.pop(context);
                          },
                        )
                      ]).show();
                  //getCameraImage(context);
                },
              ),
              IconButton(
                iconSize: 40.0,
                icon: Icon(Icons.videocam),
                onPressed: () {
                  Alert(
                      context: context,
                      title: 'Select camera or gallery for video',
                      buttons: [
                        DialogButton(
                          child: Text('Camera'),
                          onPressed: () {
                            getCameraVideo(context);
                            Navigator.pop(context);
                            //getCameraImage(context);
                          },
                        ),
                        DialogButton(
                          child: Text('Gallery'),
                          onPressed: () {
                            getGalleryVideo(context);
                            Navigator.pop(context);
                            //getGalleryImage(context);
                          },
                        )
                      ]).show();
                },
              ),
              IconButton(
                iconSize: 40.0,
                icon: Icon(Icons.send),
                onPressed: () {
                  onSubmit(
                      context, selectedIncident, textEditingController.text);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  // the input text field who's input data is a new message
  Widget buildInput(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: TextField(
          onSubmitted: (value) {
            onSubmit(context, selectedIncident, textEditingController.text);
          },
          controller: textEditingController,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              hintText: 'Enter a description'),
          textInputAction: TextInputAction.send,
          style: TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ),
    );
  }

  Future getCameraImage(BuildContext context) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        Uuid unique = Uuid();
        fileName = unique.v4() + basename(imageFile.path);
      }
    });
  }

  Future getGalleryImage(BuildContext context) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        Uuid unique = Uuid();
        fileName = unique.v4() + basename(imageFile.path);
      }
    });
  }

  Future getCameraVideo(BuildContext context) async {
    final pickedFile = await picker.getVideo(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        Uuid unique = Uuid();
        fileName = unique.v4() + basename(imageFile.path);
        videoPlayerController = VideoPlayerController.file(imageFile);

        //uploadImageToFirebase(context, imageFile, fileName);

      }
    });
    videoPlayerController.initialize().then((value) {
      setState(() {});
    });
  }

  Future getGalleryVideo(BuildContext context) async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        Uuid unique = Uuid();
        fileName = unique.v4() + basename(imageFile.path) + '.mp4';
        //uploadVideoToFirebase(context, imageFile, fileName);
      }
    });
  }

  onSubmit(BuildContext context, String incident, String description) {
    print('Incident: $incident; Description: $description');

    if (imageFile != null) {
      if (fileName.endsWith('.mp4')) {
        uploadVideoToFirebase(context, imageFile, fileName);
      } else {
        uploadImageToFirebase(context, imageFile, fileName);
      }
    } else {
      fileName = 'none';
    }
    onSendMessage(description, incident);
    Navigator.pop(context);
  }

  // Sends the input data(content) to the firebase firestore
  onSendMessage(String content, String incident) {
    //if (content.trim() == '')

    textEditingController.clear();

    var documentReference = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(documentReference, {
        'content': content,
        'image': fileName,
        'incident': incident,
        'timestamp': Timestamp.now(),
        'user': userNumber,
      });
    });
  }
}
