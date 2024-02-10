import 'package:firebase_auth/firebase_auth.dart';
import 'package:nood_food/models/nf_user.dart';

/// Authentication service layer for interacting with the backend in terms of
/// authentication of users
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  NFUser? _parseUserFromFirebaseUser(User? fbUser) {
    return fbUser == null ? null : NFUser(fbUser.uid);
  }

  /// Creates a stream on changes in user's authentication state, i.e. is
  /// logged in or not.
  Stream<NFUser?> get user {
    return _auth.authStateChanges().map(_parseUserFromFirebaseUser);
  }

  String? get userUid {
    return _auth.currentUser?.uid;
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
}
