import 'package:firebase_auth/firebase_auth.dart';
import 'package:nood_food/models/nf_user.dart';
import 'package:nood_food/services/db_service.dart';

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

  Future<NFUser?> registerWithEmail(String email, String password) async {
    UserCredential? cred;
    cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    return _parseUserFromFirebaseUser(cred.user);
  }

  Future<NFUser?> loginWithEmail(String email, String password) async {
    UserCredential? cred;
    cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
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
}
