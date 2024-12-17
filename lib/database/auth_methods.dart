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

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Authenticate user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the authenticated user's UID is in the admin collection
      DocumentSnapshot snapshot = await firebaseFirestore
          .collection('admin')
          .doc(userCredential.user!.uid)
          .get();
      if (snapshot.exists) {
        // User is an admin, allow login
        return 'success';
      } else {
        // User is not an admin, deny login
        await _auth.signOut(); // Sign out the user
        return 'You are not authorized to access this account.';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for this user.';
      } else {
        return 'Firebase Authentication Error: ${e.message}';
      }
    } on FirebaseException catch (e) {
      return 'Firebase Error: ${e.message}';
    } catch (e) {
      return 'Unexpected Error: $e';
    }
  }
}
