import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'create_petition_page.dart';
import 'petition_detail_page.dart';
import 'models/petition.dart';

class PetitionListPage extends StatefulWidget {
  const PetitionListPage({super.key});

  @override
  State<PetitionListPage> createState() => _PetitionListPageState();
}

class _PetitionListPageState extends State<PetitionListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Petition> _allPetitions = [];
  List<Petition> _filteredPetitions = [];

  @override
  void initState() {
    super.initState();
    _fetchPetitions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPetitions() async {
    // Listen to the petitions node in the Firebase Realtime Database
    DatabaseReference petitionsRef =
        FirebaseDatabase.instance.ref().child('petitions');

    petitionsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _allPetitions = data.entries
              .map((entry) => Petition.fromSnapshot(entry.key, entry.value))
              .toList();
          _filteredPetitions = _allPetitions;
        });
      }
    });
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPetitions = _allPetitions.where((petition) {
        final query = _searchController.text.toLowerCase();
        final title = petition.title.toLowerCase();
        final description = petition.description.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    });
  }

  void _createNewPetition() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePetitionPage()),
    ).then((_) {
      // Fetch petitions after creating a new petition
      _fetchPetitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Petitions'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Petitions',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _createNewPetition,
              ),
            ],
          ),
          Expanded(
            child: _filteredPetitions.isEmpty
                ? const Center(child: Text('No petitions found.'))
                : ListView.builder(
                    itemCount: _filteredPetitions.length,
                    itemBuilder: (context, index) {
                      final petition = _filteredPetitions[index];
                      return ListTile(
                        title: Text(petition.title),
                        subtitle: Text(petition.description),
                        trailing: Text(petition.date),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PetitionDetailPage(petition: petition),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
