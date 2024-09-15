import 'package:flutter/material.dart';
import 'create_petition_page.dart';
import 'petition_detail_page.dart';

class PetitionListPage extends StatefulWidget {
  const PetitionListPage({super.key});

  @override
  State<PetitionListPage> createState() => _PetitionListPageState();
}

class _PetitionListPageState extends State<PetitionListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Petition> _allPetitions = []; // Replace with actual data fetching
  List<Petition> _filteredPetitions = [];

  @override
  void initState() {
    super.initState();
    _fetchPetitions();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchPetitions() {
    // TODO: Fetch petitions from your database and assign to _allPetitions
    _allPetitions = [
      Petition(
          title: 'Save the Rainforest',
          description: 'Act now to save our forests.'),
      Petition(
          title: 'Reduce Plastic Use',
          description: 'Encourage reduction in single-use plastics.'),
    ];
    _filteredPetitions = _allPetitions;
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
    );
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
            child: ListView.builder(
              itemCount: _filteredPetitions.length,
              itemBuilder: (context, index) {
                final petition = _filteredPetitions[index];
                return ListTile(
                  title: Text(petition.title),
                  subtitle: Text(petition.description),
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

class Petition {
  final String title;
  final String description;
  int votes;

  Petition({required this.title, required this.description, this.votes = 0});
}
