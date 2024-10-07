import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/db_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service layer for interacting with the backend in terms of
/// authentication of users
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NFUser? _parseUserFromFirebaseUser(User? fbUser) {
    return fbUser == null
        ? null
        : NFUser(
            uid: fbUser.uid,
            email: fbUser.email,
            displayName: fbUser.displayName,
            photoURL: fbUser.photoURL,
            isInit: false,
            numDaysTracked: 0);
  }

  /// Creates a stream on changes in user's authentication state, i.e. is
  /// logged in or not.
  Stream<NFUser?> get user {
    return _auth.authStateChanges().map(_parseUserFromFirebaseUser);

    // return StreamGroup.merge([_auth.authStateChanges(), _auth.userChanges()])
    // .asBroadcastStream()
    // .map(_parseUserFromFirebaseUser);
  }

  String? get userUid {
    return _auth.currentUser?.uid;
  }

  NFUser? get currentUser {
    return _parseUserFromFirebaseUser(_auth.currentUser);
  }

  /// Creates a new user account with the inputted [email] and [password]. If an
  /// account with that [email] already exists, then false is return. Otherwise,
  /// false.
  Future<bool> registerWithEmail(
      String email, String password, BuildContext context) async {
    // Indeed a new user
    bool exists = await checkIfUserExists(email);
    if (!exists && context.mounted) {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    }
    return false;
  }

  Future<void> loginWithEmail(
      String email, String password, BuildContext context) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
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
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> logout() async {
    List<String> providers =
        _auth.currentUser?.providerData.map((e) => e.providerId).toList() ?? [];
    await _auth.signOut().then((value) async {
      if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
        await GoogleSignIn().signOut();
      }
    });
  }

  Future<void> updateAccountInfo(
      NFUser newUser, File? newAvatar, NFUser? oldUser) async {
    // Don't do anything if no changes occurred.
    if (newUser == oldUser && (newUser.isInit ?? false) == true) return;

    if (newAvatar != null) {
      String? photoURL = await uploadFile(newAvatar);
      await _auth.currentUser!.updatePhotoURL(photoURL);
      newUser.photoURL = photoURL;
    }
    await DBService(uid: userUid).updateUserDetails(
        newUser.email,
        newUser.dob,
        newUser.weight,
        newUser.sex,
        newUser.height,
        newUser.calorieLimit,
        newUser.activeLevel);
    await _auth.currentUser!.updateDisplayName(newUser.displayName);
  }

  /// Reauthenticates the user then deletes their account.
  Future<void> deleteUserAccount(String? confirmedPassword) async {
    List<String> providers =
        _auth.currentUser?.providerData.map((e) => e.providerId).toList() ?? [];
    await FirebaseAuth.instance.currentUser!
        .delete()
        .onError((FirebaseAuthException error, stackTrace) async {
      if (error.code == "requires-recent-login") {
        await _reauthenticate(confirmedPassword);
        await FirebaseAuth.instance.currentUser!.delete().then((value) async {
          if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
            await GoogleSignIn().signOut();
          }
        });
        return;
      }
      throw FirebaseAuthException(
          code: error.code,
          message:
              'Something went wrong when attempting to delete your account. Please try again later.');
    }).then((value) async {
      if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
        await GoogleSignIn().signOut();
      }
    });
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

  Future<bool> checkIfUserExists(String? email) async {
    if (email == null) return false;
    return (await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get())
        .docs
        .isNotEmpty;
  }

  bool isLoggedOut() {
    return _auth.currentUser == null;
  }
}
