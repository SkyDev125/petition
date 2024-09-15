import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth_wrapper.dart'; // Updated import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petitions App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode:
          ThemeMode.system, // Automatically switch based on device settings
      home: const AuthWrapper(), // Use AuthWrapper
    );
  }
}
