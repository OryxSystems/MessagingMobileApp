import 'package:flutter/cupertino.dart';

//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoadImage extends StatefulWidget {
  final String image;
  LoadImage({this.image});
  LoadImageState createState() => LoadImageState(image: image);
}

class LoadImageState extends State<LoadImage> {
  final String image;

  LoadImageState({this.image});
  //String image = 'Screenshot_1602069392.png';
  Widget build(context) {
    return Flexible(
      //FlexFit.loose,
      child: FutureBuilder(
        future: getImage(context, image),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              height: MediaQuery.of(context).size.height / 1.25,
              width: MediaQuery.of(context).size.width / 1.25,
              child: snapshot.data,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: MediaQuery.of(context).size.height / 1.25,
                width: MediaQuery.of(context).size.width / 1.25,
                child: CircularProgressIndicator());
          }
          return Container();
        },
      ),
    );
  }

// works for mobile, not for web
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
  }
}
