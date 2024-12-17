import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String firstName;
  String confrimPassword;
  String password;
  bool isAdmin; // New attribute

  UserModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.confrimPassword,
    required this.firstName,
    required this.isAdmin, // New attribute
  });

  ///Converting Object into Json Object
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'uid': uid,
        'password': password,
        'email': email,
        'confrimPassword': confrimPassword,
        'isAdmin': true, // Include isAdmin in JSON
      };

  ///
  static UserModel fromSnap(DocumentSnapshot snaps) {
    var snapshot = snaps.data() as Map<String, dynamic>;

    return UserModel(
      firstName: snapshot['firstName'],
      uid: snapshot['uid'],
      password: snapshot['password'],
      email: snapshot['email'],
      confrimPassword: snapshot['confrimPassword'],
      isAdmin: snapshot['isAdmin'] ??
          true, // Set isAdmin, default to false if not present
    );
  }
}
