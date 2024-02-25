import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  /// If the last sign in is the same as when the account was created and they
  /// did not set the displayname (which is a required field), then the user is
  /// new.
  bool get isNewUser {
    UserMetadata? metadata = _auth.currentUser?.metadata;
    return metadata?.lastSignInTime == metadata?.creationTime &&
        _auth.currentUser?.displayName == null;
  }

  Future<NFUser?> registerWithEmail(String email, String password) async {
    UserCredential? cred;
    cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    return _parseUserFromFirebaseUser(cred.user);
  }

  Future<NFUser?> loginWithEmail(String email, String password) async {
    UserCredential? cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return _parseUserFromFirebaseUser(cred.user);
  }

  Future<NFUser?> logInWithGoogle() async {
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
    UserCredential cred =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return _parseUserFromFirebaseUser(cred.user);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateAccountInfo(
      String displayName,
      DateTime? dob,
      String? sex,
      double? weight,
      double? height,
      double? calorieLimit,
      File? profilePic) async {
    await _auth.currentUser!.updateDisplayName(displayName);
    String? photoURL = await uploadFile(profilePic);
    await _auth.currentUser!.updatePhotoURL(photoURL);
    await DBService(uid: userUid)
        .updateUserDetails(dob, weight, sex, height, calorieLimit);
  }

  /// Reauthenticates the user then deletes their account.
  Future<void> deleteUserAccount(String? confirmedPassword) async {
    await _reauthenticate(confirmedPassword);
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
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
