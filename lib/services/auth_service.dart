import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nood_food/util/active_level.dart';
import 'package:nood_food/views/pages/account/account_info.dart';

/// Authentication service layer for interacting with the backend in terms of
/// authentication of users
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NFUser? _parseUserFromFirebaseUser(User? fbUser) {
    return fbUser == null
        ? null
        : NFUser(
            uid: fbUser.uid,
            displayName: fbUser.displayName,
            photoURL: fbUser.photoURL);
  }

  /// Creates a stream on changes in user's authentication state, i.e. is
  /// logged in or not.
  Stream<NFUser?> get user {
    return _auth.authStateChanges().map(_parseUserFromFirebaseUser);
  }

  String? get userUid {
    return _auth.currentUser?.uid;
  }

  NFUser? get currentUser {
    return _parseUserFromFirebaseUser(_auth.currentUser);
  }

  /// On registration, user needs to indicate display name and other info.
  Future<void> _navigateToAccountInfo(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (builder) => const AccountInfo()));
  }

  Future<void> registerWithEmail(
      String email, String password, BuildContext context) async {
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((cred) async {
      await _navigateToAccountInfo(context);
      return cred;
    });
  }

  Future<void> loginWithEmail(
      String email, String password, BuildContext context) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((cred) async {
      // Safe guard incase user did not complete setting up their acacount
      // before closing the application
      if (_auth.currentUser?.displayName == null) {
        await _navigateToAccountInfo(context);
      }
      return cred;
    });
  }

  Future<void> logInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((cred) async {
      // Make the user
      if (cred.additionalUserInfo!.isNewUser && context.mounted) {
        await _navigateToAccountInfo(context);
      }
      return cred;
    });
  }

  Future<void> logout() async {
    List<String> providers =
        _auth.currentUser?.providerData.map((e) => e.providerId).toList() ?? [];
    await _auth.signOut().then((value) async {
      if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
        await GoogleSignIn().signOut();
      }
      if (providers.contains(AppleAuthProvider.PROVIDER_ID)) {
        // TODO
      }
    });
  }

  Future<void> updateAccountInfo(
      String displayName,
      DateTime? dob,
      String? sex,
      double? weight,
      double? height,
      double? calorieLimit,
      ActiveLevel? level,
      File? profilePic) async {
    await _auth.currentUser!.updateDisplayName(displayName);
    if (profilePic != null) {
      String? photoURL = await uploadFile(profilePic);
      await _auth.currentUser!.updatePhotoURL(photoURL);
    }

    await DBService(uid: userUid)
        .updateUserDetails(dob, weight, sex, height, calorieLimit, level);
  }

  /// Reauthenticates the user then deletes their account.
  Future<void> deleteUserAccount(String? confirmedPassword) async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        await _reauthenticate(confirmedPassword);
        await FirebaseAuth.instance.currentUser!.delete();
        return;
      }
      throw FirebaseAuthException(
          code: e.code,
          message:
              'Something went wrong when attempting to delete your account. Please try again later.');
    }
  }

  /// Since this is a security-sensitive operation, Firebase needs a relatively
  /// fresh sign-in token and might throw an exception
  Future<void> _reauthenticate(String? confirmedPassword) async {
    final providerData = _auth.currentUser?.providerData.first;

    if (AppleAuthProvider.PROVIDER_ID == providerData!.providerId) {
      await _auth.currentUser!.reauthenticateWithProvider(AppleAuthProvider());
    } else if (GoogleAuthProvider.PROVIDER_ID == providerData.providerId) {
      await _auth.currentUser!.reauthenticateWithProvider(GoogleAuthProvider());
    } else if (EmailAuthProvider.PROVIDER_ID == providerData.providerId) {
      User? user = _auth.currentUser;
      if (user == null) return;
      final credential = EmailAuthProvider.credential(
          email: user.email!, password: confirmedPassword ?? '');
      try {
        await _auth.currentUser!.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        throw FirebaseAuthException(
            code: e.code,
            message: 'The current password you entered is incorrect.');
      }
    }
  }

  /// Uses Firebase Storage to save the image, then generates a photo URL for
  /// firebase auth.
  Future<String?> uploadFile(File? image) async {
    if (image == null) return null;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(_auth.currentUser!.uid)
        .child("profile_picture.jpg");
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  /// Checks if this user has an email/password provider.
  bool hasPasswordProvider() {
    List<UserInfo> providers = _auth.currentUser!.providerData;
    for (UserInfo info in providers) {
      if (info.providerId == EmailAuthProvider.PROVIDER_ID) return true;
    }
    return false;
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    // Check if current password is correct
    User? user = _auth.currentUser;
    if (user == null) return;

    await _reauthenticate(currentPassword);
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
          code: e.code,
          message:
              'There was an issue changing your password. Please try again later.');
    }
  }
}
