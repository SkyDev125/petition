class Petition {
  final String id;
  final String title;
  final String description;
  final String date;
  int votes;

  Petition({
    required this.id,
    required this.title,
    required this.description,
    required this.votes,
    required this.date,
  });

  // Convert Firebase Realtime Database snapshot to a Petition
  factory Petition.fromSnapshot(String id, Map<dynamic, dynamic> data) {
    return Petition(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      votes: data['votes'] ?? 0,
      date: data['date'] ?? '',
    );
  }

  // Convert Petition to a Map for saving to Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'votes': votes,
      'date': date,
    };
  }
}
