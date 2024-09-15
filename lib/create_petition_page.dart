import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/petition.dart';

class CreatePetitionPage extends StatefulWidget {
  const CreatePetitionPage({super.key});

  @override
  State<CreatePetitionPage> createState() => _CreatePetitionPageState();
}

class _CreatePetitionPageState extends State<CreatePetitionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _createPetition() async {
    if (_formKey.currentState!.validate()) {
      // Ensure user is signed in
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Prompt user to sign in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create a petition')),
        );
        return;
      }

      // Generate a new petition reference with a unique ID
      DatabaseReference petitionRef =
          FirebaseDatabase.instance.ref().child('petitions').push();

      // Create petition
      Petition newPetition = Petition(
        id: petitionRef.key!, // Use the generated key as the ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: formatDateTime(DateTime.now()),
        votes: 0,
      );

      try {
        // Save petition to Realtime Database
        await petitionRef.set(newPetition.toMap());

        // After async call, check if the widget is still mounted
        if (!mounted) return;

        // Navigate back to petition list
        Navigator.pop(context);
      } catch (e) {
        // After async call, check if the widget is still mounted
        if (!mounted) return;

        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create petition: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Petition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter a title'
                  : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter a description'
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createPetition,
              child: const Text('Create Petition'),
            ),
          ]),
        ),
      ),
    );
  }
}

// Example of displaying the date as text without any imports
String formatDateTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
