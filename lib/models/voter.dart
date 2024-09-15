// models/voter.dart

class Voter {
  final String email;
  final int timestamp;

  Voter({
    required this.email,
    required this.timestamp,
  });

  // Factory constructor to create a Voter from a map
  factory Voter.fromMap(Map<dynamic, dynamic> data) {
    return Voter(
      email: data['email'] ?? '',
      timestamp: data['timestamp'] ?? 0,
    );
  }

  // Method to convert a Voter instance to a map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'timestamp': timestamp,
    };
  }
}
