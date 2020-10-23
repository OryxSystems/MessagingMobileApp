import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

// works for mobile, not for web
Future<String> loadVideo(BuildContext context, String video) async {
  String vid;
  await FirebaseStorage.instance
      .ref()
      .child(video)
      .getDownloadURL()
      .then((downloadUrl) {
    vid = downloadUrl.toString();
  });
  return vid;
}
