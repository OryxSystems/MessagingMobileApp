import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class DisplayImage extends StatefulWidget {
  final Image image;
  DisplayImage({this.image});
  DisplayImageState createState() => DisplayImageState(image: image);
}

class DisplayImageState extends State<DisplayImage> {
  final Image image;
  DisplayImageState({this.image});

  Widget build(context) {
    if (image != null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Display Image'),
          ),
          body: Container(
            child: PhotoView(imageProvider: image.image),
          ));
    } else {
      Navigator.pop(context);
      return Container();
    }
  }
}

/*Widget displayImage(Image image) {
  return Container(
    child: PhotoView(imageProvider: image.image),
  );
}
*/
