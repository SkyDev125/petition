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
        } else {
          return Transaction.abort();
        }
      });

      // Record that the user has voted along with their email
      await _userVoteRef.child(user.uid).set({
        'email': user.email,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

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

  // Function to retract a vote on a petition, which decrements the vote count in the database
  Future<void> _retractVote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to retract your vote')),
      );
      return;
    }

    try {
      // Use a transaction to safely decrement the vote count
      await _petitionRef.child('votesCount').runTransaction((currentVotes) {
        if (currentVotes == null ||
            (currentVotes is int && currentVotes <= 0)) {
          return Transaction.abort();
        } else if (currentVotes is int) {
          return Transaction.success(currentVotes - 1);
        } else {
          return Transaction.abort();
        }
      });

      // Remove the user's vote record
      await _userVoteRef.child(user.uid).remove();

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        hasVoted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your vote has been retracted.')),
      );
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retract vote: $e')),
      );
    }
  }

  // Stream to listen to real-time voteCount updates
  Stream<int> getVoteCountStream() {
    return _petitionRef.child('votesCount').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is int) {
        return data;
      } else {
        return 0;
      }
    });
  }

  // Stream to listen to real-time voters' emails
  Stream<List<String>> getVotersEmailsStream() {
    return _userVoteRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <String>[];

      // Extract emails from the data
      List<String> emails = [];
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic> && value['email'] != null) {
          emails.add(value['email']);
        }
      });
      return emails;
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
                if (snapshot.hasError) {
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
              onPressed: () {
                if (hasVoted) {
                  _retractVote();
                } else {
                  _vote();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hasVoted ? Colors.red : Colors.blue,
              ),
              child: Text(hasVoted ? 'Retract Vote' : 'Vote'),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Voters:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: getVotersEmailsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error loading voters.');
                  } else if (snapshot.hasData) {
                    final emails = snapshot.data!;
                    if (emails.isEmpty) {
                      return const Text('No votes yet.');
                    }
                    return ListView.builder(
                      itemCount: emails.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(emails[index]),
                        );
                      },
                    );
                  } else {
                    return const Text('No voters found.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
