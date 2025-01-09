import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brightminds_admin/model/user_model.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot documentSnapshot = await firebaseFirestore
          .collection('admin')
          .doc(currentUser.uid)
          .get();
      return UserModel.fromSnap(documentSnapshot);
    } else {
      throw Exception("User not logged in.");
    }
  }

  Future<String> signUpUser({
    required String email,
    required String confirmPassword,
    required String firstName,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel userModel = UserModel(
        firstName: firstName,
        uid: cred.user!.uid,
        email: email,
        password: password,
        confrimPassword: confirmPassword,
        isAdmin: false, // Set isAdmin to false for regular sign-up
      );

      await firebaseFirestore
          .collection('admin')
          .doc(cred.user!.uid)
          .set(userModel.toJson());
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Fetch admin collection
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  Future<void> SignUp({
    required String email,
    required String password,
  }) async {
    try {
      // Fetch admin collection
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }
}
