import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  /// TO GET USER ID
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Adding Image to Firebase Storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    Reference reference =
        firebaseStorage.ref().child(childName).child(_auth.currentUser!.uid);

    // To consider whether it's profile or post image
    if (isPost) {
      String id = Uuid().v1();
      reference = reference.child(id);
    }
    UploadTask uploadTask = reference.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  /// Adding General File (e.g., Audio) to Firebase Storage
  Future<String> uploadMP3ToStorage(Uint8List file) async {
    String uniqueID = const Uuid().v4();
    String fileName = "$uniqueID.mp3"; // Append .mp3 extension

    Reference reference = firebaseStorage
        .ref()
        .child('ExerciseAudio')
        .child(_auth.currentUser!.uid)
        .child(fileName);

    // Set MIME type to audio/mpeg
    UploadTask uploadTask = reference.putData(
      file,
      SettableMetadata(contentType: 'audio/mpeg'),
    );

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    print("MP3 Uploaded: $downloadURL");
    return downloadURL;
  }
}
