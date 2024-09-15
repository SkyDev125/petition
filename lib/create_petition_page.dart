import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'petition_list_page.dart'; // For the Petition class

class CreatePetitionPage extends StatefulWidget {
  const CreatePetitionPage({super.key});

  @override
  State<CreatePetitionPage> createState() => _CreatePetitionPageState();
}

class _CreatePetitionPageState extends State<CreatePetitionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _createPetition() async {
    if (_formKey.currentState!.validate()) {
      // Ensure user is signed in
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await _signInAnonymously();
      }

      // Create petition
      Petition newPetition = Petition(
        title: _titleController.text,
        description: _descriptionController.text,
      );

      // TODO: Save petition to your database

      // Navigate back to petition list
      Navigator.pop(context);
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      // Handle errors
      print(e);
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
