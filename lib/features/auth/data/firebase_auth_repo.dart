/*
Using Fiirebase as my backend.
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:starter/features/auth/domain/entities/app_user.dart';
import 'package:starter/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  // Firebase Access.
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Login with Email & Password Method.
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      //Attempt to Sign in with email and password.
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //Create user
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      return user;
    } catch (e) {
      throw Exception('Login failed $e');
    }
  }

  //Register with Email & Password Method.
  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      //Attempt Registration
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //Create the User
      AppUser user = AppUser(uid: userCredential.user!.uid, email: email);

      return user;
    } catch (e) {
      throw Exception('Registration Failed $e');
    }
  }

  //Delete Account.
  @override
  Future<void> deleteAccount() async {
    try {
      // Get the current user.
      final user = firebaseAuth.currentUser;

      //Check if this user is logged in.
      if (user == null) throw Exception("No User logged in");

      //Lastly delete the account and logout.
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete Account $e');
    }
  }

  //Get Current user.
  @override
  Future<AppUser?> getCurrentUser() async {
    // Get the current logged in user from firebase
    final firebaseUser = firebaseAuth.currentUser;

    //Check if the user is logged in.
    if (firebaseUser == null) return null;

    //
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  //Logout
  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  //Password Reset.
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your inbox ";
    } catch (e) {
      return "An error occured $e";
    }
  }
}
