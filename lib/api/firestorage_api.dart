import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class FirestorageApi {
  static Future removePhoto(String photo_before) async {
    try {
      if (photo_before != '') {
        if (Uri.parse(photo_before).host == 'firebasestorage.googleapis.com') {
          await FirebaseStorage.instance
              .refFromURL(photo_before)
              .delete()
              .then((value) => print('Delete Image Success'));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static Future uploadPhoto(File _image, String folder) async {
    if (_image == null) {
      return '';
    } else {
      String fileName =
          '${folder}_${DateTime.now().millisecondsSinceEpoch}${p.extension(_image.path)}';
      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child('$folder/$fileName').putFile(_image);
      if (snapshot.state == TaskState.success) {
        final String url = await snapshot.ref.getDownloadURL();
        return url;
      }
    }
  }

  static Future uploadSlip(File _image) async {
    if (_image == null) {
      return '';
    } else {
      String fileName = DateTime.now().toString() + ".jpg";
      var storage = FirebaseStorage.instance;
      TaskSnapshot snapshot =
          await storage.ref().child('Slip/$fileName').putFile(_image);
      if (snapshot.state == TaskState.success) {
        final String url = await snapshot.ref.getDownloadURL();
        return url;
      }
    }
  }
}
