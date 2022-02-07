import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class PickImage {
  late File _image;
  final picker = ImagePicker();
  final bool isGroup;

  PickImage({this.isGroup = false});

  imageUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    String id = isGroup ? user!.uid + Timestamp.now().toString() : user!.uid;
    final ref =
        FirebaseStorage.instance.ref().child('user_images').child(id + '.jpg');
    await ref.putFile(
      _image,
    );
    final url = await ref.getDownloadURL();
    if (!isGroup) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'image': url,
      });
    }
    return url;
  }

  removeImage() async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'image': '',
    });
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(user.uid + '.jpg');
    await ref.delete();
  }

  pickImagefromGallery() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
    _image = File(pickedFile!.path);
    return imageUpload();
  }

  pickImagefromCamera() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    _image = File(pickedFile!.path);
    return imageUpload();
  }
}
