import 'dart:typed_data';

import 'package:brightminds_admin/model/exsersice_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brightminds_admin/database/storage_methods.dart';
import 'package:brightminds_admin/model/service_model.dart';
import 'package:uuid/uuid.dart';

class Database {
  Future<String> addExercise(
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
        await FirebaseFirestore.instance.collection('letters').doc(uuid).set({
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
}
