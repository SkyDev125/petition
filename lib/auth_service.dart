// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to authentication changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google using Firebase Auth's signInWithPopup
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Optionally, set any custom parameters if needed
      // googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      // Sign in with a popup and return the UserCredential
      return await _auth.signInWithPopup(googleProvider);
    } catch (e, stackTrace) {
      // Handle error
      print('Error during Google sign-in: $e');
      print('Stack Trace: $stackTrace');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // No need to sign out from GoogleSignIn explicitly when using signInWithPopup
  }
}
