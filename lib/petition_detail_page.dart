import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'petition_list_page.dart'; // For the Petition class

class PetitionDetailPage extends StatefulWidget {
  final Petition petition;

  const PetitionDetailPage({super.key, required this.petition});

  @override
  State<PetitionDetailPage> createState() => _PetitionDetailPageState();
}

class _PetitionDetailPageState extends State<PetitionDetailPage> {
  bool hasVoted = false;

  void _vote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Prompt to sign in
      await _signInAnonymously();
    }

    // Update votes
    setState(() {
      if (!hasVoted) {
        widget.petition.votes++;
        hasVoted = true;
      }
    });
    // TODO: Save vote to your database
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
        title: Text(widget.petition.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.petition.description),
            const SizedBox(height: 20),
            Text('Votes: ${widget.petition.votes}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: hasVoted ? null : _vote,
              child: Text(hasVoted ? 'You have voted' : 'Vote'),
            ),
          ],
        ),
      ),
    );
  }
}
