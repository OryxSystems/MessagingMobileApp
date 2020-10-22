import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

uploadImageToFirebase(
    BuildContext context, File imageFile, String fileName) async {
  StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('uploads/$fileName');
  StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  taskSnapshot.ref.getDownloadURL().then((value) => print('Done: $value'));
}

uploadVideoToFirebase(
    BuildContext context, File imageFile, String fileName) async {
  StorageReference ref =
      FirebaseStorage.instance.ref().child('videos/$fileName');
  StorageUploadTask uploadTask =
      ref.putFile(imageFile, StorageMetadata(contentType: 'video/mp4'));
  StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  taskSnapshot.ref.getDownloadURL().then((value) => print('Done: $value'));
}
