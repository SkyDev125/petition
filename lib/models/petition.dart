class Petition {
  final String id;
  final String title;
  final String description;
  final String date;
  Map<String, bool> votes; // Votes tracked by user IDs
  int votesCount; // Separate votesCount field

  Petition({
    required this.id,
    required this.title,
    required this.description,
    required this.votes,
    required this.votesCount,
    required this.date,
  });

  factory Petition.fromSnapshot(String id, Map<dynamic, dynamic> data) {
    return Petition(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      votes: Map<String, bool>.from(data['votes'] ?? {}),
      votesCount: data['votesCount'] ?? 0, // Initialize votesCount
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'votes': votes,
      'votesCount': votesCount, // Include votesCount
      'date': date,
    };
  }
}
