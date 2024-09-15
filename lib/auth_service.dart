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

      // Set custom parameters to hint the email domain
      googleProvider.setCustomParameters({'hd': 'tecnico.ulisboa.pt'});

      // Sign in with a popup and return the UserCredential
      UserCredential userCredential =
          await _auth.signInWithPopup(googleProvider);

      // Check if the email domain matches
      if (userCredential.user?.email?.endsWith('@tecnico.ulisboa.pt') ??
          false) {
        return userCredential;
      } else {
        // Sign out if the email domain does not match
        await signOut();
        print('Error: Only @tecnico.ulisboa.pt emails are allowed.');
        return null;
      }
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
