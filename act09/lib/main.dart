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
}