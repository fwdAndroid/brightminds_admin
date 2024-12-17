import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  String uuid;
  String level;
  String photoURL;
  String categoryName;

  ServiceModel({
    required this.uuid,
    required this.categoryName,
    required this.level,
    required this.photoURL,
  });

  ///Converting Object into Json Object
  Map<String, dynamic> toJson() => {
        'photoURL': photoURL,
        'level': level,
        'categoryName': categoryName,
        'uuid': uuid,
      };

  ///
  static ServiceModel fromSnap(DocumentSnapshot snaps) {
    var snapshot = snaps.data() as Map<String, dynamic>;

    return ServiceModel(
      categoryName: snapshot['categoryName'],
      photoURL: snapshot['photoURL'],
      level: snapshot['level'],
      uuid: snapshot['uuid'],
    );
  }
}
