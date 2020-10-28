import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

StorageUploadTask uploadImageToFirebase(
    BuildContext context, File imageFile, String fileName) {
  StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('uploads/$fileName');
  StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
  return uploadTask;
  //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //taskSnapshot.ref.getDownloadURL().then((value) => print('Done: $value'));
}

StorageUploadTask uploadVideoToFirebase(
    BuildContext context, File imageFile, String fileName) {
  StorageReference ref =
      FirebaseStorage.instance.ref().child('videos/$fileName');
  StorageUploadTask uploadTask =
      ref.putFile(imageFile, StorageMetadata(contentType: 'video/mp4'));
  return uploadTask;
  //StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //setState(() {});
  //taskSnapshot.ref.getDownloadURL().then((value) => print('Done: $value'));
}
