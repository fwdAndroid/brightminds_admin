import 'package:cloud_firestore/cloud_firestore.dart';

class ExersciseModel {
  String uuid;
  String characterName;
  String photoURL;
  String audioURL; // New field
  String levelCategory;
  String levelSubCategory;

  ExersciseModel({
    required this.uuid,
    required this.characterName,
    required this.photoURL,
    required this.audioURL,
    required this.levelCategory,
    required this.levelSubCategory,
  });

  /// Convert Object to JSON
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'characterName': characterName,
        'photoURL': photoURL,
        'audioURL': audioURL,
        'levelCategory': levelCategory,
        'levelSubCategory': levelSubCategory
      };

  /// Convert JSON to Object
  static ExersciseModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return ExersciseModel(
      uuid: snapshot['uuid'],
      levelCategory: snapshot['levelCategory'],
      levelSubCategory: snapshot['levelSubCategory'],
      characterName: snapshot['characterName'],
      photoURL: snapshot['photoURL'],
      audioURL: snapshot['audioURL'],
    );
  }
}
