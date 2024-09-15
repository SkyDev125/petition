import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'models/petition.dart';

class PetitionDetailPage extends StatefulWidget {
  final Petition petition;

  const PetitionDetailPage({super.key, required this.petition});

  @override
  State<PetitionDetailPage> createState() => _PetitionDetailPageState();
}

class _PetitionDetailPageState extends State<PetitionDetailPage> {
  bool hasVoted = false;
  late DatabaseReference _petitionRef;
  late DatabaseReference _userVoteRef;

  @override
  void initState() {
    super.initState();
    _petitionRef = FirebaseDatabase.instance
        .ref()
        .child('petitions')
        .child(widget.petition.id);
    _userVoteRef = _petitionRef.child('votes');
    _checkIfUserHasVoted();
  }

  // Check if the user has already voted by looking up their vote in the database
  Future<void> _checkIfUserHasVoted() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not signed in; assume hasn't voted
      return;
    }

    try {
      // Check if the user has already voted on this petition
      DatabaseReference voteRef = _userVoteRef.child(user.uid);
      DataSnapshot snapshot = await voteRef.get();

      if (!mounted) return; // Check if the widget is still mounted

      if (snapshot.exists) {
        setState(() {
          hasVoted = true;
        });
      }
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking vote status: $e')),
      );
    }
  }

  // Function to vote on a petition, which increments the vote count in the database
  Future<void> _vote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Optionally, you can prompt the user to sign in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to vote')),
      );
      return;
    }

    try {
      // Use a transaction to safely increment the vote count
      await _petitionRef.child('votesCount').runTransaction((currentVotes) {
        if (currentVotes == null) {
          return Transaction.success(1);
        } else if (currentVotes is int) {
          return Transaction.success(currentVotes + 1);
        } else if (currentVotes is double) {
          return Transaction.success(currentVotes.toInt() + 1);
        } else {
          return Transaction.abort();
        }
      });

      if (!mounted) return; // Check if the widget is still mounted

      // Record that the user has voted
      await _userVoteRef.child(user.uid).set(true);

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        hasVoted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for voting!')),
      );
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to vote: $e')),
      );
    }
  }

  // Stream to listen to real-time voteCount updates
  Stream<int> getVoteCountStream() {
    return _petitionRef.child('votesCount').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is int) {
        return data;
      } else if (data is double) {
        return data.toInt();
      } else {
        return 0;
      }
    });
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
            Text(
              widget.petition.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            StreamBuilder<int>(
              stream: getVoteCountStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Votes: ...',
                      style: TextStyle(fontSize: 16));
                } else if (snapshot.hasError) {
                  return const Text('Votes: Error',
                      style: TextStyle(fontSize: 16));
                } else {
                  return Text('Votes: ${snapshot.data}',
                      style: const TextStyle(fontSize: 16));
                }
              },
            ),
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

// Example of displaying the date as text without any imports
String formatDateTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}
