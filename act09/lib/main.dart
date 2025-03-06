import 'package:flutter/material.dart';
import 'database_helper.dart';

// Main function
void main() async {
  // Widget binding is initialized to use async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SQLite database
  await DatabaseHelper.instance.database;

  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      // Set the initial home screen to the FoldersScreen widget.
      home: const FoldersScreen(),
    );
  }
}

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

    @override
    State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {

  // Eventually holds the list of folders from DB
  late Future<List<Map<String, dynamic>>> foldersFuture;

  @override
  void initState() {
    super.initState();
    // Query all folders from DB
    foldersFuture = DatabaseHelper.instance.queryAllFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with a title for Folders screen
      appBar: AppBar(
        title: const Text('Folders'),
      ),
body: FutureBuilder<List<Map<String, dynamic>>>(
        future: foldersFuture,
        builder: (context, snapshot) {
          
          // While waiting for data, loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Once data available, display list of folders
          if (snapshot.hasData) {
            final folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                
                // Extract folder id and name from folder map
                int folderId = folder[DatabaseHelper.columnFolderId];
                String folderName = folder[DatabaseHelper.columnFolderName];

                // Create a list tile for each folder
                return ListTile(
                  title: Text(folderName),
                  trailing: const Icon(Icons.arrow_forward),
                  
                  // When tapped, navigate to CardsScreen for selected folder
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardsScreen(
                          folderId: folderId,
                          folderName: folderName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          // If no folders are found, display error message
          return const Center(child: Text('No folders found.'));
        },
      ),
    );
  }
}

// Displays cards inside a folder
class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const CardsScreen({super.key, required this.folderId, required this.folderName});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {

  // Eventually holds list of cards
  late Future<List<Map<String, dynamic>>> cardsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the cards for the current folder
    _refreshCards();
  }
  
  // Refreshes cards by querying the DB
  void _refreshCards() {
    setState(() {
      cardsFuture = DatabaseHelper.instance.queryCardsByFolder(widget.folderId);
    });
  }

  Future<void> _addCard() async {
  
  }

  Future<void> _deleteCard(int cardId) async {
  
  }

  @override
  Widget build(BuildContext context) {
  
  }

}