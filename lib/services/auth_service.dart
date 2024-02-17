import 'package:firebase_auth/firebase_auth.dart';
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
          );
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

  /// If the last sign in is the same as when the account was created, then the
  /// user is new.
  bool get isNewUser {
    UserMetadata? metadata = _auth.currentUser?.metadata;
    return metadata?.lastSignInTime == metadata?.creationTime;
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

  Future<void> updateAccountInfo(String displayName, DateTime? dob, String? sex,
      double? weight, double? height, double? calorieLimit) async {
    await _auth.currentUser!.updateDisplayName(displayName);
    await DBService(uid: userUid)
        .updateUserDetails(dob, weight, sex, height, calorieLimit);
  }

  Future<void> deleteUserAccount() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      print(e);
      // Handle general exception
    }
  }

  /// Since this is a security-sensitive operation, Firebase needs a relatively
  /// fresh sign-in token and might throw an exception
  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData = _auth.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await _auth.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }
      await _auth.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
    }
  }
}
