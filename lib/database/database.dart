import 'dart:typed_data';

import 'package:brightminds_admin/model/exsersice_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brightminds_admin/database/storage_methods.dart';
import 'package:brightminds_admin/model/service_model.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Database {
  Future<void> addExercise({
    required String levelSubCategory,
    required String levelCategory,
    required String characterName,
    required Uint8List file,
    required Uint8List audioFile,
    required String mediaType, // Media type (audio or video)
    required Function(double) onProgress, // Progress callback
  }) async {
    try {
      // Generate a UUID for the exercise document
      String uuid = Uuid().v4(); // Generates a unique UUID

      // Firebase Storage references for image and media
      Reference imageRef =
          FirebaseStorage.instance.ref().child('exercises/$uuid/image.png');
      Reference mediaRef = FirebaseStorage.instance
          .ref()
          .child('exercises/$uuid/media.$mediaType');

      // Upload the image with progress tracking
      UploadTask imageUploadTask = imageRef.putData(file);
      imageUploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred / event.totalBytes;
        onProgress(progress / 2); // Image upload is 50% of the total progress
      });

      // Wait for the image upload to complete
      await imageUploadTask;

      // Upload the media with progress tracking
      UploadTask mediaUploadTask = mediaRef.putData(audioFile);
      mediaUploadTask.snapshotEvents.listen((event) {
        double progress = event.bytesTransferred / event.totalBytes;
        onProgress(0.5 + (progress / 2)); // Media upload is the other 50%
      });

      // Wait for the media upload to complete
      await mediaUploadTask;

      // Get the download URLs for the uploaded files
      String imageUrl = await imageRef.getDownloadURL();
      String mediaUrl = await mediaRef.getDownloadURL();

      // Create an exercise model or map
      Map<String, dynamic> exerciseModel = {
        'levelSubCategory': levelSubCategory,
        'levelCategory': levelCategory,
        'characterName': characterName,
        'photoURL': imageUrl, // URL of the uploaded image
        'audioURL': mediaUrl, // URL of the uploaded media
        'mediaType': mediaType, // Media type
        'uuid': uuid
      };

      // Store the data in Firestore
      await FirebaseFirestore.instance.collection('letters').doc(uuid).set({
        'exercises': FieldValue.arrayUnion([exerciseModel]),
      });

      // Print the document UUID (ID) to the console after upload
      print("Exercise added successfully with UUID: $uuid");
    } catch (e) {
      print("Error adding exercise: $e");
    }
  }

  Future<String> addServices(
      {required String categoryName,
      required String level,
      required Uint8List file}) async {
    String res = 'Wrong Service Name';
    try {
      if (categoryName.isNotEmpty || level.isNotEmpty) {
        String photoURL = await StorageMethods()
            .uploadImageToStorage('ServicesPics', file, true);

        var uuid = Uuid().v4();
        //Add User to the database with modal
        ServiceModel userModel = ServiceModel(
            categoryName: categoryName,
            level: level,
            uuid: uuid,
            photoURL: photoURL);
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(uuid)
            .set(userModel.toJson());
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> addExtras(
      {required String categoryName,
      required String level,
      required Uint8List file}) async {
    String res = 'Wrong Service Name';
    try {
      if (categoryName.isNotEmpty || level.isNotEmpty) {
        String photoURL = await StorageMethods()
            .uploadImageToStorage('ExtraPics', file, true);

        var uuid = Uuid().v4();
        //Add User to the database with modal
        ServiceModel userModel = ServiceModel(
            categoryName: categoryName,
            level: level,
            uuid: uuid,
            photoURL: photoURL);
        await FirebaseFirestore.instance
            .collection('extras')
            .doc(uuid)
            .set(userModel.toJson());
        res = 'success';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> addExtraExercise(
      {required String characterName,
      required Uint8List file, // Image file
      required Uint8List audioFile, // Audio file
      required String levelSubCategory,
      required String levelCategory}) async {
    String res = 'Something went wrong';
    try {
      if (characterName.isNotEmpty) {
        print("Uploading image...");
        String photoURL = await StorageMethods()
            .uploadImageToStorage('ExercisePics', file, true);

        print("Uploading audio...");
        String audioURL = await StorageMethods().uploadMP3ToStorage(audioFile);

        String uuid = Uuid().v4();
        print("Creating exercise model...");
        ExersciseModel exerciseModel = ExersciseModel(
          levelCategory: levelCategory,
          levelSubCategory: levelSubCategory,
          characterName: characterName,
          uuid: uuid,
          photoURL: photoURL,
          audioURL: audioURL,
        );

        // Ensure category document exists, if not, create it.

        // Add exercise to the array field 'exercises' in the category document.
        print("Adding exercise to Firestore...");
        await FirebaseFirestore.instance
            .collection('extraletters')
            .doc(uuid)
            .set({
          'exercises': FieldValue.arrayUnion([exerciseModel.toJson()]),
        });

        res = 'success';
      } else {
        res = 'Category or Character Name is missing';
      }
    } catch (e) {
      print("Error in addExercise: $e");
      res = e.toString();
    }
    return res;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchFilteredExercises({
    required String categoryName,
    required String level,
  }) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('letters').get();

      List<Map<String, dynamic>> filteredExercises = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> exercises =
            List<Map<String, dynamic>>.from(data['exercises'] ?? []);

        // Filter exercises where categoryName and level match
        filteredExercises.addAll(exercises.where((exercise) =>
            exercise['levelSubCategory'] == categoryName &&
            exercise['levelCategory'] == level));
      }

      return filteredExercises;
    } catch (e) {
      print('Error fetching filtered exercises: $e');
      return [];
    }
  }
  //Open Paste Dialog
}
