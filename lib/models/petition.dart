// models/petition.dart

import 'voter.dart'; // Import the Voter class

class Petition {
  final String id;
  final String title;
  final String description;
  final String date;
  final Map<String, Voter> votes; // Votes tracked by user IDs with Voter info
  final int votesCount; // Separate votesCount field

  Petition({
    required this.id,
    required this.title,
    required this.description,
    required this.votes,
    required this.votesCount,
    required this.date,
  });

  // Factory constructor to create a Petition from a snapshot
  factory Petition.fromSnapshot(String id, Map<dynamic, dynamic> data) {
    // Safely parse the votes map
    Map<String, Voter> parsedVotes = {};
    if (data['votes'] != null) {
      data['votes'].forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          parsedVotes[key as String] = Voter.fromMap(value);
        }
      });
    }

    return Petition(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      votes: parsedVotes,
      votesCount: data['votesCount'] ?? 0,
      date: data['date'] ?? '',
    );
  }

  // Method to convert a Petition instance to a map
  Map<String, dynamic> toMap() {
    // Convert the votes map to a map of maps
    Map<String, dynamic> votesMap = {};
    votes.forEach((key, voter) {
      votesMap[key] = voter.toMap();
    });

    return {
      'title': title,
      'description': description,
      'votes': votesMap,
      'votesCount': votesCount,
      'date': date,
    };
  }
}
