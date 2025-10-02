import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<AppUser?> get userProfileStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      // owner info should be in Firestore (not implemented here)
      return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        name: '',
        role: 'owner',
      );
    });
  }

  Future<void> signInOwner(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async => await _auth.signOut();
}
