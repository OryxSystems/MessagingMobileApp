import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

// works for mobile, not for web
Future<Widget> loadImage(BuildContext context, String image) async {
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
