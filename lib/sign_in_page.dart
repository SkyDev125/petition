import 'package:flutter/material.dart';
import 'auth_service.dart';

class SignInPage extends StatelessWidget {
  final AuthService authService;

  const SignInPage({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: () async {
            final userCredential = await authService.signInWithGoogle();
            if (userCredential == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign-in failed')),
              );
            }
          },
        ),
      ),
    );
  }
}
